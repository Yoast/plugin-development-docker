#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

# Source files containing needed functions
source ./config/functions.sh

prepare_files

source .env

#this function is defined in either setup_win.sh or setup_mac.sh
echo "Running make script for ${PLATFORM}"
platform_setup
