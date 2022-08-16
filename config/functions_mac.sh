#!/bin/bash

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
# Function set up nsf for usage #/System/Volumes/Data -alldirs -mapall=501:20 localhost
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function setup_NFS(){
    if [ -z "$(cat /etc/exports | grep '/System/Volumes/Data ')" ]; then
        echo update exports
        echo "/System/Volumes/Data -alldirs -mapall=$UID:20 localhost" | sudo tee -a /etc/exports
        sudo nfsd restart
    fi
    if [ -z "$(cat /etc/nfs.conf | grep -e '^nfs.server.mount.require_resv_port = 0$')" ]; then
        echo update exports
        echo "nfs.server.mount.require_resv_port = 0" | sudo tee -a /etc/nfs.conf
        sudo nfsd restart
    fi
}


#######################################
# Function setup the crt file used to be trused by the system
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function setup_crt_file() {
    if [[ "$(security verify-cert -c ./config/certs/wordpress.test.crt 2>&1 )" != "...certificate verification successful." ]]; then
        echo "install cert needed please enter password in popup to add to keychain:"
        sudo security add-trusted-cert  -r trustRoot -k /Library/Keychains/System.keychain ./config/certs/wordpress.test.crt
    fi
}

#######################################
# Function checkes ranger minimal version tasks
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None will Exit if not ok
#######################################
function check_minimal_ranger_version() {
    Echo "Check ranger minimal required version"
    # Default rancher location, it may be different depending on the user deciding to install the app somewhere else.
    default_rancher_loc='/Applications/Rancher Desktop.app/Contents/Resources/resources/linux/rancher-desktop.appdata.xml'
    rancher_desktop_version=$(grep -E "release version=\".+?\"" "${default_rancher_loc}" | cut -d '"' -f 2)
    rancher_should_be="1.1.1"
    # Compare the versions and exit if the used version is too old.
    result=$(min_required_verion $rancher_desktop_version $rancher_should_be)
    if [[ "$result" = "false" ]]; then
        echo "Your Rancher Desktop version is outdated (${rancher_desktop_version}). Please update to at least ${rancher_should_be}"
        exit 1
    else
        echo OK
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
    setup_NFS
    setup_crt_file
    platform_independent_make $hostfile
    kill_port_80_usage
    cp -n ./config/macOS/docker-compose.override.yml ./docker-compose.override.yml
    check_minimal_ranger_version
}


