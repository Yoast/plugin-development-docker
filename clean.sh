#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

docker-compose down --volumes --remove-orphans
docker-compose stop
docker-compose rm -fv
rm -rf wordpress
git checkout -- wordpress/.gitkeep

# Remove our saved WordPress table prefix.
rm -f .env

# clean up wp-config.php files
rm -rf ./config/basic/wp-config.php && mkdir -p ./config/basic/   && touch ./config/basic/wp-config.php
rm -rf ./config/woocommerce/wp-config.php && mkdir -p ./config/woocommerce/   && touch ./config/woocommerce/wp-config.php
rm -rf ./config/nightly/wp-config.php && mkdir -p ./config/nightly/   && touch ./config/nightly/wp-config.php
rm -rf ./config/multisite/wp-config.php && mkdir -p ./config/multisite/   && touch ./config/multisite/wp-config.php
rm -rf ./config/multisitedomain/wp-config.php && mkdir -p ./config/multisitedomain/   && touch ./config/multisitedomain/wp-config.php
rm -rf ./config/standalone/wp-config.php && mkdir -p ./config/standalone/   && touch ./config/standalone/wp-config.php

case $1 in
    -a|--all)
        echo "Option '--all' defined. Removing non-default config files."
        rm -f ./config/config.sh
        rm -f ./config/php.ini
        ;;
esac
