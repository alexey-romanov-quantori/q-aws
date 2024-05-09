import hashlib
import tempfile
import time

from django.contrib.auth import get_user_model
from django.core.files import File
from django.db import models
from django.utils.timezone import now
from celery import shared_task


User = get_user_model()


class Computation(models.Model):

    STATUS_NOT_STARTED = 'not started'
    STATUS_PENDING = 'pending'
    STATUS_IN_PROGRESS = 'in progress'
    STATUS_SUCCESS = 'success'
    STATUS_FAILED = 'failed'
    STATUSES = [STATUS_PENDING, STATUS_IN_PROGRESS, STATUS_SUCCESS, STATUS_FAILED, STATUS_NOT_STARTED]

    # Metadata
    owner = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    start_date = models.DateTimeField('datetime of computation start', auto_now_add=True)
    end_date = models.DateTimeField('datetime of computation end', null=True, blank=True)
    status = models.CharField('status of computation', max_length=15, default=STATUS_NOT_STARTED)

    input_file = models.FileField('input file', help_text='input file to calculate hash')
    result_file = models.FileField('result file', blank=True, null=True)

    def __str__(self):
        return f'Computation {self.pk}'

    def start_computation(self):  # lets name it "dispatcher"
        ...
        # if local:
        #   run celery.task.delay(self.pk)
        # if cloud:
        #   run boto3... - this part a bit later

    def compute(self):
        time.sleep(3)
        input_file_sha256_hash = self._get_input_file_sha256_hash()
        self._write_result_file(input_file_sha256_hash)
        self.update_status(self.STATUS_SUCCESS)


    def update_status(self, status: str, update_end_date=False):
        self.status = status
        if update_end_date:
            self.end_date = now()
        self.save()

    def _get_input_file_sha256_hash(self):
        sha = hashlib.new('sha256')
        with self.input_file.open('rb') as f:
            sha.update(f.read())
        return sha.hexdigest()

    def _write_result_file(self, string_to_write, result_file_name='result.txt'):
        with tempfile.TemporaryFile() as tmp_file:
            result_string = string_to_write
            tmp_file.write(bytes(result_string, encoding='utf-8'))
            django_tmp_file = File(tmp_file, name=result_file_name)
            self.result_file.save(name=result_file_name, content=django_tmp_file, save=False)
            self.save()


@shared_task
def start_computation_task(computation_id: int):
    """
    Task starts computation
    """
    computation = Computation.objects.get(pk=computation_id)
    computation.compute()
