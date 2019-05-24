#!/bin/bash

yum -y install nfs-utils

mkdir /var/nfsshare
mkdir /var/nfsshare/devstuff
mkdir /var/nfsshare/testing
mkdir /var/nfsshare/home_dirs

chmod -R 777 /var/nfsshare/

systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

cd /var/nfsshare/

echo "/var/nfsshare/home_dirs *(rw,sync,no_all_squash)
/var/nfsshare/devstuff  *(rw,sync,no_all_squash)
/var/nfsshare/testing   *(rw,sync,no_all_squash)" >> /etc/exports

systemctl restart nfs-server

yum -y install net-tools
