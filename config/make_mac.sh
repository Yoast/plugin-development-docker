#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

source config/config.sh
source config/make_functions.sh

hostfile=''

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

function platform_make() {
	
	verify_hostfile /etc/hosts

	change_hostfile ${BASIC_HOST:-basic.wordpress.test}
	change_hostfile ${WOOCOMMERCE_HOST:-woocommerce.wordpress.test}
	change_hostfile ${MULTISITE_HOST:-multisite.wordpress.test}
	change_hostfile test.${MULTISITE_HOST:-multisite.wordpress.test}
	change_hostfile translate.${MULTISITE_HOST:-multisite.wordpress.test}
	change_hostfile ${STANDALONE_HOST:-standalone.wordpress.test}
	change_hostfile ${BASIC_DATABASE_HOST:-basic-database.wordpress.test}
	change_hostfile ${WOOCOMMERCE_DATABASE_HOST:-woocommerce-database.wordpress.test}
	change_hostfile ${MULTISITE_DATABASE_HOST:-multisite-database.wordpress.test}
	change_hostfile ${STANDALONE_DATABASE_HOST:-standalone-database.wordpress.test}

	kill_port_80_usage
}