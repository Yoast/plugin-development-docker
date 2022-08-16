#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

if ! [[ -f './config/php.ini' ]]; then
    echo '[!] Warning: config file(s) not found. Please run ./setup.sh first.'
	exit 1
fi

set +e
source .env
set -e

source ./config/functions.sh

### for upgrade from make.sh to setup.sh
if  [[ ! -f .env ]] ; then
    echo "setup was has not yet finisched, running it now"
    ./setup.sh
fi

if [[ -z "$@" ]]; then
    CONTAINERS=basic-wordpress
else
    CONTAINERS="$@"
fi

check_if_container_is_known

echo "Building containers: $CONTAINERS"

#define constants
URL_basic_wordpress="https://${BASIC_HOST:-basic.wordpress.test}"
URL_woocommerce_wordpress="https://${WOOCOMMERCE_HOST:-woocommerce.wordpress.test}"
URL_multisite_wordpress="https://${MULTISITE_HOST:-multisite.wordpress.test}"
URL_standalone_wordpress="https://${STANDALONE_HOST:-standalone.wordpress.test}"
URL_multisitedomain_wordpress="https://${MULTISITEDOMIAN_HOST:-multisitedomain.wordpress.test}"
URL_nightly_wordpress="https://${NIGHTLY_HOST:-nightly.wordpress.test}"

# Get environment variable for the Wordpress DB Table Prefix

STOPPING=false

trap stop_docker INT
trap stop_docker INT

platform_tasks
echo ho
build_containers

boot_containers

await_install_wordpress

await_containers

echo "Containers have booted! Happy developing!"
sleep 2

echo "Outputting logs now:"
docker compose logs -f &
PROCESS=$!

#run platform specific maintenance tasks every 5 seconds 
while [ "$STOPPING" != 'true' ]; do
	
	sleep 5
done
