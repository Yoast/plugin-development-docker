#!/bin/bash

## This script starts the docker containers which allow yoast.test and plugins
## development container to run side-by-side.
##
## This is being done with an extra nginx proxy which listens to port 80 and
## has knowledge about the containers in both environments and which hostname
## they should be linked to.
##
## More info on https://yoast.atlassian.net/wiki/spaces/DEV/pages/1813446743/Run+plugin+development+docker+next+to+the+Yoast.test+docker

if [[ -z "$@" ]]; then
    CONTAINERS=basic-wordpress
else
    CONTAINERS="$@"
fi

bash ./scripts/start-with-config.sh docker-compose-full-development-environment.yml $CONTAINERS
