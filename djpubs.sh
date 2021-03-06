#!/bin/bash

yum install -y epel-release
yum update -y
yum install python-pip -y

sudo pip install --upgrade pip
sudo pip install virtualenv
sudo pip install --upgrade pip

yum install -y python-devel postgresql-devel
yum install -y telnet

mkdir /opt/myproject
cd /opt/myproject

yum -y install wget

wget https://raw.githubusercontent.com/passwordlandia/capstone/master/settings.py

sudo pip install virtualenv
virtualenv myprojectenv
source myprojectenv/bin/activate && pip install django psycopg2-binary && django-admin.py startproject myproject .

mv -f /opt/myproject/settings.py /opt/myproject/myproject/settings.py

source myprojectenv/bin/activate && python manage.py makemigrations && python manage.py migrate && python manage.py runserver 0.0.0.0:8000
