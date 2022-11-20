#!/bin/bash

Public_IP=`curl http://169.254.169.254/latest/meta-data/public-ipv4`

DIR=/root/django-app/venv

Running_process=`systemctl is-active django.service`
if [ $Running_process == 'active' ];
then
  systemctl stop django.service
  echo "Application has been stopped." >> /root/django-app/app.log
else
  echo "there is no process is running, hence we are moving further" >> /root/django-app/app.log
fi

echo "This is: $DIR"
if [ -d "$DIR" ];
then
  echo "found venv path, hence we are removing it"
  rm -rf $DIR
  python3 -m pip install -r /root/django-app/requirements.txt
else
  python3 -m pip install -r /root/django-app/requirements.txt
fi

sed -i "/ALLOWED_HOSTS/c\ALLOWED_HOSTS = ['$Public_IP']" /root/django-app/djangoapp/settings.py
systemctl start django.service

Status_check=`systemctl is-active django.service`
if [ $Status_check == 'active' ];
then
echo "Application is succesfully ruuning on $Public_IP:8000" >> /root/django-app/app.log
else
  echo "Application Startup failed an error. Please check." >> /root/django-app/app.log
  exit 1
fi
