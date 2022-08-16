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
	sudo apt-get update
	sudo apt-get -y install pass
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


