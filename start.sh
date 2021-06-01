#!/bin/bash

if [[ -z "$@" ]]; then
    CONTAINERS=basic-wordpress
else
    CONTAINERS="$@"
fi

bash ./scripts/start-with-config.sh docker-compose.yml $CONTAINERS
