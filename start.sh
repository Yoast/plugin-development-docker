#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

if ! [[ -f './config/php.ini' ]]; then
    echo '[!] Warning: config file(s) not found. Please run ./make.sh first.'
	exit 1
fi

source .env
source platform.sh
source ./config/start_functions.sh

if [[ -z "$@" ]]; then
    CONTAINERS=basic-wordpress
else
    CONTAINERS="$@"
fi

echo "Building containers: $CONTAINERS"

#define constants
URL_basic_wordpress="http://${BASIC_HOST:-basic.wordpress.test}"
URL_woocommerce_wordpress="http://${WOOCOMMERCE_HOST:-woocommerce.wordpress.test}"
URL_multisite_wordpress="http://${MULTISITE_HOST:-multisite.wordpress.test}"
URL_standalone_wordpress="http://${STANDALONE_HOST:-standalone.wordpress.test}"
URL_multisitedomain_wordpress="http://${MULTISITEDOMIAN_HOST:-multisitedomain.wordpress.test}"
URL_nightly_wordpress="http://${NIGHTLY_HOST:-nightly.wordpress.test}"

# Get environment variable for the Wordpress DB Table Prefix

STOPPING=false

trap stop_docker INT
trap stop_docker INT

#######################################
# Stop containers in the docker-compose file
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function stop_docker {
    STOPPING=true
    docker-compose down
    wait $PROCESS
    exit
}

#######################################
# Create Dockerfile from template
# echo starting contianers...
# Arguments:
#   None
# Outputs:
#   None
#######################################
function create_dockerfile {
    echo "Starting containers:"
    for CONTAINER in $CONTAINERS; do
        echo "  - $CONTAINER"
    done
}
#######################################
# Build all images from compose file
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function build_containers() {
    echo "Ensuring all containers are built."
    docker-compose build --pull --parallel $CONTAINERS
}

#######################################
# Bring up containers from compose file
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function boot_containers() {
    echo "Booting containers."
    docker-compose up --detach $CONTAINERS
}

#######################################
# Wait untill containers have booted
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
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

#######################################
# Compare 2 semver variables
# Globals:
#   None
# Arguments:
#   version 1, version 2
# Outputs:
#   0 for equal, 1 for >, 2 for <
#######################################
function compare_ver(){
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

find_platform

if [[ "$PLATFORM" == WINDOWS ]]; then
	source config/start_win.sh
   
else
	source config/start_mac.sh
fi

platform_tasks

build_containers

boot_containers

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
	
	sleep 5
done
