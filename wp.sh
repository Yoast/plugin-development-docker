#!/bin/bash
case "$1" in
    basic-wordpress|woocommerce-wordpress|multisite-wordpress)
        CONTAINER=`shift`
        ;;
    *)
        CONTAINER=`docker ps --filter "ancestor=wordpress" --filter "label=com.docker.compose.project.working_dir=$(pwd)" --format "{{.ID}}" | tr -d '[:space:]'`
        ;;
esac
echo "docker exec -ti $CONTAINER wp $@"
