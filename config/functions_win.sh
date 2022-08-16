#!/bin/bash

# Set path to hostfile
hostfile=/mnt/c/Windows/System32/drivers/etc/hosts

#######################################
# Function setup pass needed for docker pulling
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function setup_pass() {
	echo "check if pass is installed"
	if [[ -z "$(dpkg -s pass | grep Status | grep installed)" ]]; then
		sudo apt-get update && apt-get -y install pass
	else
		echo "OK"
	fi
}

#######################################
# Function that groups make tasks
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function platform_setup() {
	platform_independent_make $hostfile
	setup_pass
}


