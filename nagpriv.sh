#!/bin/bash 

yum -y install nagios

systemctl enable nagios
systemctl start nagios

setenforce 0

sed -i 's/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1, 10.138.1.5/g' /etc/nagios/nrpe.cfg


yum install -y httpd
systemctl enable httpd
systemctl start httpd

yum install -y nagios-plugins-all
yum install -y nagios-plugins-nrpe
yum install -y nrpe

systemctl enable nrpe
systemctl start nrpe

echo '########### NRPE CONFIG LINE #######################
define command{
command_name check_nrpe
command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}' >> /etc/nagios/objects/commands.cfg
 
 systemctl /restart nagios

 /usr/sbin/nagios -v /etc/nagios/nagios.cfg

 systemctl restart nagios
 
 setenforce 0
