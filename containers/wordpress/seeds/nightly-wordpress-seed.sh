#!/bin/bash
echo "$(source "/usr/local/bin/core-install.sh")"
echo "***Installing Wordpress Nightly***"
echo "$(wp core update --version=nightly --force --allow-root --path=/var/www/html)"
echo "$(wp core update-db --allow-root --path=/var/www/html)"
echo "$(wp faker core content --pages=5)"
