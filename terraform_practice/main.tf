# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"

}

resource "aws_security_group" "allowed_ports" { 
  name = "allowed_ports" 
  description = "Allow Port Traffic" 
  vpc_id = aws_vpc.patriciaVPC.id
 
  ingress { 
    from_port = 80 
    to_port = 80 
    protocol = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
  } 


  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }


  ingress {
    from_port = 8089
    to_port = 8089
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port = 9997
    to_port = 9997
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }



  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  } 

}
 

# Create a VPC
resource "aws_vpc" "patriciaVPC" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "PatriciaVPC"
  }
}

resource "aws_subnet" "patriciapubsub" {
  vpc_id     = aws_vpc.patriciaVPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "TerraformPubSub"
  }
}

resource "aws_subnet" "patriciaprivsub" {
  vpc_id     = aws_vpc.patriciaVPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "TerraformPrivSub"
  }
}


resource "aws_internet_gateway" "patriciagw" {
  vpc_id     = aws_vpc.patriciaVPC.id

  tags = {
    Name = "PatriciaVPCgw"
  }
}

resource "aws_route_table" "demo_rt" {
  vpc_id                    = aws_vpc.patriciaVPC.id

  route {
    cidr_block              = "0.0.0.0/0"
    gateway_id          = aws_internet_gateway.patriciagw.id
  }

  tags = {
    Name = "demo_rt"
  }
}

resource "aws_route_table_association" "demo_rt" {
  subnet_id                 = aws_subnet.patriciapubsub.id
  route_table_id            = aws_route_table.demo_rt.id
}

# Create an ec2_instance
resource "aws_instance" "terraform_ec2" {
  ami =  data.aws_ami.web.id
  instance_type = var.instancetype
  key_name      = var.key_name
  count		= 2 
  monitoring    =  false
  vpc_security_group_ids = [aws_security_group.allowed_ports.id]
  subnet_id 		 = aws_subnet.patriciapubsub.id
  associate_public_ip_address = true
  depends_on 		      = [aws_internet_gateway.patriciagw]	
  user_data = "${file("splunkinstall.sh")}"

  tags = {
   "Name" = "${var.name}-${count.index + 1}"
  }
}

data "aws_ami" "web" {
    most_recent = true 
    owners      = ["367105360882"] # Canonical
 
    filter {
       name     = "name"
       values   = ["ami_pat*"]
    }
  } 


output "ip" {
    value = "${join(",", aws_instance.terraform_ec2.*.public_ip)}"
}
