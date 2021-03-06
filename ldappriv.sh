#!/bin/bash

yum -y install git
gitclone https://github.com/passwordlandia/capstone.git
yum -y install openldap-servers openldap-clients

cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap. /var/lib/ldap/DB_CONFIG

systemctl enable slapd
systemctl start slapd

yum -y install httpd
yum -y install epel-release
yum -y install phpldapadmin

setsebool -P httpd_can_connect_ldap on

systemctl enable httpd
systemctl start httpd

sed -i 's,Require local,#Require local\n Require all granted,g' /etc/httpd/conf.d/phpldapadmin.conf

cp capstone/config.php  /etc/phpldapadmin/config.php 
chown ldap:apache /etc/phpldapadmin/config.php

systemctl restart httpd.service

echo "phpldapadmin is now up and running"
echo "configuring ldap and ldapadmin"

newsecret=$(slappasswd -g)
newhash=$(slappasswd -s "$newsecret")
echo -n "$newsecret" > /root/ldap_admin_pass
chmod 0600 /root/ldap_admin_pass

echo -e "dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=itc299,dc=local
\n
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=ldapadm,dc=itc299,dc=local
\n
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $newhash" >> db.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f db.ldif

echo -e 'dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external, cn=auth" read by dn.base="cn=ldapadm,dc=itc299,dc=local" read by * none' > monitor.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f monitor.ldif
openssl req -new -x509 -nodes -out /etc/openldap/certs/itc299ldapcert.pem -keyout /etc/openldap/certs/itc299ldapkey.pem -days 365 -subj "/C=US/ST=WA/L=Seattle/O=SCC/OU=IT/CN=itc299.local"

chown -R ldap. /etc/openldap/certs/nti*.pem

echo -e "dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/openldap/certs/itc299ldapcert.pem

dn: cn=config
changetype: modify
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/openldap/certs/itc299ldapkey.pem" > certs.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f certs.ldif
slaptest -u
unalias cp

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif 
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

echo -e "dn: dc=itc299,dc=local
dc: itc299
objectClass: top
objectClass: domain
dn: cn=ldapadm ,dc=itc299,dc=local
objectClass: organizationalRole
cn: ldapadm
description: LDAP Manager
dn: ou=People,dc=itc299,dc=local
objectClass: organizationalUnit
ou: People
dn: ou=Group,dc=itc299,dc=local
objectClass: organizationalUnit
ou: Group" > base.ldif

ldapadd -x -W -D "cn=ldapadm,dc=itc299,dc=local" -f base.ldif -y /root/ldap_admin_pass

slaptest -u

setenforce 0

systemctl restart httpd
