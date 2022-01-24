#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

# Source files containing needed functions
source config/config.sh
source config/make_functions.sh

# Set path to hostfile
hostfile=/etc/hosts

#######################################
# Check if port 80 is in use, and kill the process 
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function kill_port_80_usage () {    
    echo "Checking if port 80 is free to use"
    if lsof -nP +c 15 | grep LISTEN | grep -s -E "[0-9]:80 "; then
        select yn in "Stop apachectl to use docker" "Leave it (I will fix it myself!)"; do
           case $yn in
                "Stop apachectl so we can use docker" )  
                    echo "Need sudo to STOP apachectl"
                        sudo apachectl stop
                    break
                ;;
                "Leave it (I will fix it myself!)" ) break;;
            esac
        done
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
function platform_make() {	
	platform_independent_make $hostfile
	kill_port_80_usage
}