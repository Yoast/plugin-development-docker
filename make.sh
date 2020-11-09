#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

source platform.sh

function prepare_files() {
	# Remove corrupt php.ini folder, if existing.
	[[ -d './config/php.ini' ]] && rm -rf './config/php.ini'

	cp -n config/php.ini.default config/php.ini
	cp -n config/config.sh.default config/config.sh
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