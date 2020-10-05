#!/bin/bash

PLATFORM='UNKNOWN'

function find_platform {
	if [ "$OSTYPE" == "msys" ]; then 
		PLATFORM=WINDOWS 
	elif [ "$OSTYPE" == "cygwin" ]; then		
		PLATFORM=WINDOWS
	else
		PLATFORM=APPLE
	fi
    echo "Platform = $PLATFORM"
}

find_platform