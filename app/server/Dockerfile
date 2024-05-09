FROM python:3.10
ENV PYTHONUNBUFFERED=1

RUN apt update && apt upgrade -y && apt install -y python3-dev

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --upgrade pip wheel && pip3 install -r requirements.txt

COPY . /app/

RUN adduser django_user

RUN mkdir -p /django_volume/media \
    && mkdir /django_volume/static \
    && chown -R django_user /django_volume

USER django_user
