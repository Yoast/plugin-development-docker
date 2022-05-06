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
    case ${OSTYPE} in
        msys|cywgin)
            PLATFORM=WINDOWS
            ;;
        linux-gnu) 
            PLATFORM=LINUX
            ;;
        darwin*)
            if [[ "$(sysctl -n machdep.cpu.brand_string | grep Intel)" ]] 
            then
                PLATFORM=APPLE
            else
                PLATFORM=APPLE_M1
            fi
            ;;
        *) 
            PLATFORM=APPLE
            ;;
    esac
}
