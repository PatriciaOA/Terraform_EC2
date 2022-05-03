
#!/bin/bash
downloadadd="https://download.splunk.com/products/splunk/releases/8.2.5/linux/splunk-8.2.5-77015bc7a462-Linux-x86_64.tgz"

splunkpkg="splunk-8.2.5-77015bc7a462-Linux-x86_64.tgz"

#loginpass="welcome90"

sudo -i 

yum update -y

yum install wget -y

useradd splunk

cd /tmp

wget -O "$splunkpkg" "$downloadadd"

tar -xvzf "$splunkpkg" -C /opt

chown -R splunk:splunk /opt/splunk

su - splunk

/opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd welcome90

exit


/opt/splunk/bin/splunk enable boot-start -user splunk

chown -R splunk:splunk /opt/splunk

su - splunk

/opt/splunk/bin/splunk stop

sleep 180

/opt/splunk/bin/splunk start	


