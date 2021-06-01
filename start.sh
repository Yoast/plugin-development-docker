#!/bin/bash

if [[ -z "$@" ]]; then
    CONTAINERS=basic-wordpress
else
    CONTAINERS="$@"
fi

bash ./scripts/start_with_config.sh docker-compose.yml $CONTAINERS
