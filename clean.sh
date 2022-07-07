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

case $1 in
    -a|--all)
        echo "Option '--all' defined. Removing non-default config files."
        rm -f ./config/config.sh
        rm -f ./config/php.ini
        ;;
esac
