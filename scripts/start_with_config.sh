#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

if ! [[ -f './config/php.ini' ]]; then
    echo '[!] Error: config file(s) not found. Please run ./make.sh first.'
	exit 1
fi

source scripts/platform.sh
source config/config.sh

if [[ -z "$@" ]]; then
    echo '[!] Error: First argument should be a config file.'
    exit 1;
fi

# First argument is the config file.
CONFIG="$1"

# Remove first argument.
shift 1

if [[ -z "$@" ]]; then
    CONTAINERS=basic-wordpress
else
    CONTAINERS="$@"
fi

#define constants
URL_basic_wordpress="http://${BASIC_HOST:-basic.wordpress.test}"
URL_woocommerce_wordpress="http://${WOOCOMMERCE_HOST:-woocommerce.wordpress.test}"
URL_multisite_wordpress="http://${MULTISITE_HOST:-multisite.wordpress.test}"
URL_standalone_wordpress="http://${STANDALONE_HOST:-standalone.wordpress.test}"
URL_multisitedomain_wordpress="http://${MULTISITE_HOST:-multisite.wordpress.test}"

DB_PORT_basic_wordpress=1987
DB_PORT_woocommerce_wordpress=1988
DB_PORT_multisite_wordpress=1989
DB_PORT_standalone_wordpress=1990
DB_PORT_multisitedomain_wordpress=1991

USER_ID=`id -u`
GROUP_ID=`id -g`
STOPPING=false

trap stop_docker INT
trap stop_docker INT
function stop_docker {
    STOPPING=true
    docker-compose down
    wait $PROCESS
    exit
}

function create_dockerfile {
    DOCKERTEMPLATE='./containers/wordpress/Dockerfile.template'
    DOCKERFILE='./containers/wordpress/Dockerfile'
    if [ ! -f "$DOCKERFILE" ]; then
        echo -n "Creating Dockerfile from template. $DOCKERTEMPLATE => $DOCKERFILE"
        cp "$DOCKERTEMPLATE" "$DOCKERFILE"

        sed -i -e "s/\$UID/${USER_ID}/g" "$DOCKERFILE"
        sed -i -e "s/\$GID/${GROUP_ID}/g" "$DOCKERFILE"
    fi

    echo "Starting containers:"
    for CONTAINER in $CONTAINERS; do
        echo "  - $CONTAINER"
    done
}

function build_containers() {
    echo "Ensuring all containers are built."
    docker compose build --pull --parallel $CONTAINERS
}

function boot_containers() {
    echo "Booting containers."
    docker compose --file ./docker-compose-full-development-environment.yml up --detach $CONTAINERS
}

function await_containers() {
    echo "Waiting for containers to boot..."
    local BOOTED=false

    for CONTAINER in $CONTAINERS; do
        URL_VAR="URL_${CONTAINER//-/_}"
        URL=${!URL_VAR}
        while [ "$BOOTED" != "true"  ]; do
            if curl -I "$URL" 2>/dev/null | grep -q -e "HTTP/1.1 200 OK" -e "HTTP/1.1 302 Found"; then
                BOOTED=true
            else
                sleep 2
                echo "Waiting for $CONTAINER to boot... Checking $URL"
            fi
        done
        #Reset for next container
        BOOTED=false
    done
}

find_platform

if [[ "$PLATFORM" == WINDOWS ]]; then
	source scripts/start_win.sh
else
	# supports mac and linux
	source scripts/start_mac.sh
fi

create_dockerfile

build_containers

boot_containers

#platform specific
await_database_connections

#platform specific
install_wordpress

await_containers

echo "Containers have booted! Happy developing!"
sleep 2

echo "Outputting logs now:"
docker-compose logs -f &
PROCESS=$!

#run platform specific maintenance tasks every 5 seconds
while [ "$STOPPING" != 'true' ]; do
	platform_tasks
	sleep 5
done
