# Generated by Django 4.1.7 on 2023-03-23 14:42

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Computation',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('start_date', models.DateTimeField(auto_now_add=True, verbose_name='datetime of computation start')),
                ('end_date', models.DateTimeField(blank=True, null=True, verbose_name='datetime of computation end')),
                ('status', models.CharField(default='not started', max_length=15, verbose_name='status of computation')),
                ('input_file', models.FileField(help_text='input file to calculate hash', upload_to='', verbose_name='input file')),
                ('result_file', models.FileField(blank=True, null=True, upload_to='', verbose_name='result file')),
                ('owner', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]