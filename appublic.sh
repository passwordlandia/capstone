#!/bin/bash

yum -y clean all
yum -y update
yum -y install httpd

firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=110/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload

#commenting out my welcome.conf file
sed -i 's/^/#/g' /etc/httpd/conf.d/welcome.conf

# Creating our index.html
echo -e "<html> \n<h1> Welcome to my Capstone Project!</h1> \n</html>" > /var/www/html/index.html    

#I will enable and start my apache too
systemctl enable httpd
systemctl start httpd

