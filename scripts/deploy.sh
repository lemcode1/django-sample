#!/bin/bash


Public_IP=`curl http://169.254.169.254/latest/meta-data/public-ipv4`

DIR=/root/django-app/venv

Running_PID=`ps -ef | grep "venv/bin/python" | grep -v grep | awk '{print $2}'`
if [ -z "$Running_PID" ]
then
	echo "there is no process is running, hence we are moving further" >> /root/django-app/app.log
else
	kill -9 $Running_PID
fi

echo "Application has been stopped." >> /root/django-app/app.log

if [ -d "$DIR" ];
then
	python3 -m venv ./venv --prompt django-app-env
	source venv/bin/activate
	python3 -m pip install -r requirements.txt
else
  source venv/bin/activate
  python3 -m pip install -r requirements.txt
  sed -i "/ALLOWED_HOSTS/c\ALLOWED_HOSTS = ['$Public_IP']" /root/django-app/djangoapp/settings.py
  nohup python manage.py runserver 0.0.0.0:8000 &>/dev/null &
fi

Status_check=`curl -o - -I  $Public_IP:8000 | head -n1 | awk '{print $2}'`
if ["$Status_check == 200" ]
then
echo "Application is succesfully ruuning on $Public_IP:8000" >> /root/django-app/app.log
else
  echo "Application Startup failed an error. Please check." >> /root/django-app/app.log
  exit 1
fi
