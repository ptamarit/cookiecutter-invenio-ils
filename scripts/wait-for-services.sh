#!/usr/bin/env bash

# -*- coding: utf-8 -*-
#
# This file is part of Invenio.
#
# Copyright (C) 2022 CERN.
#
# Invenio is free software; you can redistribute it and/or modify it
# under the terms of the MIT License; see LICENSE file for more details.

# Verify that all services are running before continuing
check_ready() {
    RETRIES=20
    while ! $2
    do
        echo "Waiting for $1, $((RETRIES--)) remaining attempts..."
        sleep 15
        if [ $RETRIES -eq 0 ]
        then
            echo "Couldn't reach $1"
            exit 1
        fi
    done
}

_db_check(){ docker-compose exec --user postgres db bash -c "pg_isready" &>/dev/null; }
check_ready "Postgres" _db_check

_search_check(){ curl --output /dev/null --silent --head --fail http://localhost:9200 &>/dev/null; }
check_ready "Opensearch" _search_check

_redis_check(){ docker-compose exec cache bash -c 'redis-cli ping' | grep 'PONG' &> /dev/null; }
check_ready "Redis" _redis_check

_rabbit_check(){ docker-compose exec mq bash -c "rabbitmqctl status" &>/dev/null; }
check_ready "RabbitMQ" _rabbit_check