#!/bin/bash
docker-compose down --volumes --remove-orphans
docker-compose stop
docker-compose rm -fv
rm -rf wordpress
git checkout -- wordpress/.gitkeep

case $1 in
    -a|--all)
        echo "Option '--all' defined. Removing non-default config files."
        rm -f ./config/config.sh
        rm -f ./config/php.ini
        rm -f ./containers/wordpress/Dockerfile
        ;;
esac
