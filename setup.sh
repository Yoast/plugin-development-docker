#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1


# Source files containing needed functions
source ./config/setup_functions.sh
source ./config/platform.sh


prepare_files
source .env
find_platform


if [ "$PLATFORM" == WINDOWS ]; then 
	source config/setup_win.sh
else
	# supports mac 
	source config/setup_mac.sh
fi

#this function is defined in either setup_win.sh or setup_mac.sh
echo "Running make script for ${PLATFORM}"
platform_setup
