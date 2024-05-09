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
    password = "admin"
    email = "e@e.ee"
    User.objects.create_superuser(username=username, password=password, email=email)
EOF

echo "Starting django dev-server"
python manage.py runserver 0.0.0.0:80
