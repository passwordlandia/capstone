#! /bin/bash
apt-get update
apt-get install apache2 -y
sed -i '/Listen 80/c\Listen 8000' /etc/apache2/ports.conf
sed -i '/\/c\\' /etc/apache2/sites-enabled/000-default.conf
service apache2 restart
echo '<!doctype html><html><body><h1>lbpubli2</h1></body></html>' | tee /var/www/html/index.html
