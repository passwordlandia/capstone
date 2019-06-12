#! /bin/bash
apt-get update -y
apt-get install apache2 -y
service apache2 restart
echo '<!doctype html><html><body><h1>lbs2publ</h1></body></html>' | tee /var/www/html/index.html
