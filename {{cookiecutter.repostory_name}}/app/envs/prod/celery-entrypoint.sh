#!/bin/sh
set -eu

# below we define two workers types (each may have any concurrency);
# each worker may have its own settings
WORKERS="master worker"
OPTIONS="-A {{cookiecutter.django_project_name}} -E -l ERROR --pidfile=/var/run/celery-%n.pid --logfile=/var/log/celery-%n.log"

# set up settings for workers and run the latter;
# here events from "celery" queue (default one, will be used if queue not specified)
# will go to "master" workers, and events from "worker" queue go to "worker" workers;
# by default there are no workers, but each type of worker may scale up to 4 processes
nice celery multi start $WORKERS $OPTIONS \
    -Q:master celery --autoscale:master=$CELERY_MASTER_CONCURRENCY,0 \
    -Q:worker worker --autoscale:worker=$CELERY_WORKER_CONCURRENCY,0

trap "celery multi stop $WORKERS $OPTIONS; exit 0" SIGINT SIGTERM
tail -f /var/log/celery-*.log
