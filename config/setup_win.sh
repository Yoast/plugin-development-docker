#!/bin/bash

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