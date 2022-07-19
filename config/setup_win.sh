#!/bin/bash

# Set path to hostfile
hostfile=/mnt/c/Windows/System32/drivers/etc/hosts

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
}
