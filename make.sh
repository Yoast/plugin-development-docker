#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

source platform.sh

# Set environment variable for the Wordpress DB Table Prefix.
# Save this in a file so it is not random every boot (clean.sh removes this file).
if [ ! -f ./config/wp-table-prefix ]; then
  WORDPRESS_TABLE_PREFIX="$(LC_ALL=C tr -dc a-z < /dev/urandom | head -c 5 | xargs)_"
  echo $WORDPRESS_TABLE_PREFIX > ./config/wp-table-prefix
  echo "WP table prefix: $WORDPRESS_TABLE_PREFIX"
fi

function prepare_files() {
	# Remove corrupt php.ini folder, if existing.
	[[ -d './config/php.ini' ]] && rm -rf './config/php.ini'

	cp  config/php.ini.default config/php.ini
	cp  config/config.sh.default config/config.sh
}

prepare_files
find_platform

if [ "$PLATFORM" == WINDOWS ]; then 
	source config/make_win.sh
else
	# supports mac and ubuntu
	source config/make_mac.sh
fi

#this function is defined in either make_win.sh or make_mac.sh
echo "Running make script for ${PLATFORM}"
platform_make