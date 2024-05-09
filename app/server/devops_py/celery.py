import os

from celery import Celery
from django.conf import settings

# Set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'devops_py.settings')

app = Celery('devops_py')

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
# - namespace='CELERY' means all celery-related configuration keys
#   should have a `CELERY_` prefix.
app.config_from_object('django.conf:settings', namespace='CELERY')

app.conf.broker_url = f'redis://{settings.REDIS_HOST}:6379/0'
app.conf.result_backend = f'redis://{settings.REDIS_HOST}:6379/0'

# Load task modules from all registered Django apps.
app.autodiscover_tasks()
