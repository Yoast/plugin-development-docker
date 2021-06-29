#!/bin/bash

PLATFORM='UNKNOWN'

#######################################
# Find the OS of the host 
# Globals:
#   PLATFORM
# Arguments:
#   None
# Outputs:
#   None
#######################################
function find_platform {
	if [[ "$OSTYPE" =~ (msys|cygwin) ]]; then 
		PLATFORM=WINDOWS 
	else
		PLATFORM=APPLE
	fi
    echo "Platform = $PLATFORM"
}
