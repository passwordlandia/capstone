#!/bin/bash

#I have to clean up yum first
yum -y clean all
#Then I will update it
yum -y update
#And we have to install apache
yum -y install httpd

#Another thing I have to do is add in apache to get past my firewalls etc.
#And then I will reload the firewalls
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload

#commenting out my welcome.conf file
sed -i 's/^/#/g' /etc/httpd/conf.d/welcome.conf

# Creating our index.html
echo -e "<html> \n<h1> Welcome to my Capstone Project!</h1> \n</html>" > /var/www/html/index.html    

#I will enable and start my apache too
systemctl enable httpd
systemctl start httpd

