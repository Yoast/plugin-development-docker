#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

# Source files containing needed functions
source config/config.sh
source config/make_functions.sh

# Set path to hostfile
hostfile=C:/windows/system32/drivers/etc/hosts

#######################################
# Function that groups make tasks
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function platform_make() {
	platform_independent_make $hostfile
}