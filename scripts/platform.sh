#!/bin/bash

PLATFORM='UNKNOWN'

function find_platform {
	if [[ "$OSTYPE" =~ (msys|cygwin) ]]; then 
		PLATFORM=WINDOWS 
	else
		PLATFORM=APPLE
	fi
    echo "Platform = $PLATFORM"
}
