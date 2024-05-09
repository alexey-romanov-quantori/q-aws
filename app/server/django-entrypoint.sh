#!/bin/bash

echo "Collect static files"
python manage.py collectstatic --noinput

echo "Apply database migrations"
python manage.py migrate

echo "Creating superuser if not exist"
python manage.py shell <<EOF
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    username = "admin"
    password = "tmp_passwd_2023!"
    email = "e@e.ee"
    User.objects.create_superuser(username=username, password=password, email=email)
EOF

echo "Starting uwsgi server"
uwsgi --chdir=/app \
  --module=soufle_sirna.wsgi:application \
  --env DJANGO_SETTINGS_MODULE=soufle_sirna.settings \
  --master --pidfile=/tmp/project-master.pid \
  --http=0.0.0.0:80 --processes=5 --uid=1000 --gid=1000 --harakiri=20 --max-requests=5000 --vacuum
