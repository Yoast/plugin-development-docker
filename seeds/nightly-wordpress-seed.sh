#!/bin/bash
echo "$(source "${BASH_SOURCE%/*}/core-install.sh")"
echo "***Installing Wordpress Nightly***"
echo "$(wp core update --version=nightly --force --allow-root --path=/var/www/html)"
echo "$(wp faker core content --pages=5)"