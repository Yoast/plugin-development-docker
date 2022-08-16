#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

PLATFORM='UNKNOWN'

#######################################
# Check if Hostfile is present 
# Globals:
#   None
# Arguments:
#   Path to Hostfile
# Outputs:
#   None
#######################################
function verify_hostfile () {
	local hostfile=$1
	if [ ! -f "$hostfile" ]; then
		echo "host file not found at ${hosts_candidate} - aborting..."            
		exit 1
	fi
}

#######################################
# If the hostfile does not have a empty line create one 
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function check_hosts_newline () {
    hosts_lastchar=$(tail -c 1 "$hostfile")
    [[ "$hosts_lastchar" != "" ]] && echo '' | sudo tee -a "$hostfile"
}

#######################################
# Add entry to hostfile
# Globals:
#   None
# Arguments:
#   path_to_hostfile
#   URL
# Outputs:
#   None
#######################################
function change_hostfile () {
    local path_to_hostfile=$1
	local URL=$2
	echo -n "Checking hostfile entry for: ${URL}... "

    if grep -q -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" "$path_to_hostfile"; then
        if grep -q -E "^127\.0\.0\.1[[:space:]]+$URL" "$path_to_hostfile"; then
            echo "OK"
        else
            echo "Found this entry:"
            grep -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" "$path_to_hostfile";
            select yn in "Change it to use docker" "Leave it"; do
                case $yn in
                    "Change it to use docker" )
                        echo "Need sudo to edit path_to_hostfile"
                        check_hosts_newline
                        grep -v -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" "$path_to_hostfile" | sudo tee "$path_to_hostfile" > /dev/null
                        echo "127.0.0.1 $URL" | sudo tee -a "$path_to_hostfile" > /dev/null
                        break
                    ;;
                    "Leave it" ) break;;
                esac
            done
        fi
    else
        echo "Adding, need sudo"
        check_hosts_newline
        echo "127.0.0.1       $URL" | sudo tee -a "$path_to_hostfile" > /dev/null
    fi
}

#######################################
# Regardless of platform, prepare the hostfile
# Globals:
#   None
# Arguments:
#   path_to_hostfile
# Outputs:
#   None
#######################################
function platform_independent_make() {
	local path_to_hostfile=$1
	verify_hostfile "$path_to_hostfile"

	change_hostfile "$path_to_hostfile" "${BASIC_HOST:-basic.wordpress.test}"
	change_hostfile "$path_to_hostfile" "${WOOCOMMERCE_HOST:-woocommerce.wordpress.test}"
	change_hostfile "$path_to_hostfile" "${MULTISITE_HOST:-multisite.wordpress.test}"
	change_hostfile "$path_to_hostfile" "test.${MULTISITE_HOST:-multisite.wordpress.test}"
	change_hostfile "$path_to_hostfile" "translate.${MULTISITE_HOST:-multisite.wordpress.test}"
	change_hostfile "$path_to_hostfile" "${STANDALONE_HOST:-standalone.wordpress.test}"
    change_hostfile "$path_to_hostfile" "${NIGHTLY_HOST:-nightly.wordpress.test}"
	change_hostfile "$path_to_hostfile" "${MULTISITEDOMAIN_HOST:-multisitedomain.wordpress.test}"
	change_hostfile "$path_to_hostfile" "test.${MULTISITEDOMAIN_HOST:-multisitedomain.wordpress.test}"
	change_hostfile "$path_to_hostfile" "translate.${MULTISITEDOMAIN_HOST:-multisitedomain.wordpress.test}"

    
}

#######################################
# Regardless of platform, make empty wp-config.php the files
# Globals:
#   None
# Arguments:
#   folder_name
# Outputs:
#   None
#######################################
function setup_wp-config.php() {
# clean up wp-config.php files
    # Remove corrupt wp-config.php folder, if existing.
    [[ -d ./config/$1/wp-config.php ]] && rm -rf ./config/$1/wp-config.php
    #setup empyy file is not already there
    [[ ! -f ./config/$1/wp-config.php ]] && mkdir -p ./config/$1/  && touch ./config/$1/wp-config.php && echo "setup clean wp-config.php for $1"

}


#######################################
# Regardless of platform, prepare the files
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################

function prepare_files() {
	# Remove corrupt php.ini folder, if existing.
	[[ -d ./config/php.ini ]] && rm -rf ./config/php.ini
	
    [[ ! -f ./config/php.ini ]] && cp  ./config/php.ini.default ./config/php.ini
    
	# Set environment variable for the Wordpress DB Table Prefix. and UID and GUI neede for file sysyem access on host system
	# Save this in a file so it is not random every boot (clean.sh removes this file).
	if [ ! -f .env ]; then
  		WORDPRESS_TABLE_PREFIX="$(LC_ALL=C tr -dc a-z < /dev/urandom | head -c 5 | xargs)_"  
  		cat .env.default | sed -e "s/UID=.*/UID=$(id -u)/" | sed -e "s/GID=.*/GID=$(id -g)/" | sed -e "s/WORDPRESS_TABLE_PREFIX=.*/WORDPRESS_TABLE_PREFIX=$WORDPRESS_TABLE_PREFIX/"  > .env
  		echo "WP table prefix: $WORDPRESS_TABLE_PREFIX"
	fi
    for name in basic woocommerce nightly multisite multisitedomain standalone
    do 
        setup_wp-config.php $name
    done
}

#######################################
# wait for WordPress to be configuerd and setup not present
# Globals:
#   CONTAINERS
# Arguments:
#   None
# Outputs:
#   None
#######################################
function await_install_wordpress() {
    for CONTAINER in $CONTAINERS; do
        echo -n "Waiting for WordPress install and setup to finish in container $CONTAINER..."
		docker exec -ti "$CONTAINER" /bin/bash -c 'until [[ -f /tmp/done ]]; do echo -n "."; sleep 1; done'
        echo 'WordPress is setup.'
    done
}


#######################################
# check if parameeters are falit.
# Globals:
#   CONTAINERS
# Arguments:
#   None
# Outputs:
#   None
#######################################
function check_if_container_is_known() {
    for CONTAINER in $CONTAINERS; do
        case "$CONTAINER" in
            "woocommerce-wordpress"|"basic-wordpress"|"nightly-wordpress"|"standalone-wordpress"|"multisitedomain-wordpress"|"multisite-wordpress") 
            : ;;
            *) 
            echo "requested $CONTAINER has no config"
            exit 1 ;;
        esac
    done

}

#######################################
# Wait untill containers have booted
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function await_containers() {
    echo "Waiting for containers to respond to http requests..."
    local BOOTED=false

    for CONTAINER in $CONTAINERS; do
        URL_VAR="URL_${CONTAINER//-/_}"
        URL=${!URL_VAR}
        echo -n "Waiting for $URL .."
        while [ "$BOOTED" != "true"  ]; do
            if curl -kI "$URL" 2>/dev/null | grep -q -e "HTTP/1.1 200 OK" -e "HTTP/1.1 302 Found" -e "HTTP/2 302" -e "HTTP/2 200" -e "HTTP/1.1 301 Moved Permanently"; then
                BOOTED=true
            else
                sleep 1
                echo -n "."
            fi
        done
        echo "$URL is responding"
        #Reset for next container
        BOOTED=false
    done
}



#######################################
# Stop containers in the docker-compose file
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function stop_docker {
    STOPPING=true
    docker compose down
    wait $PROCESS
    exit
}

#######################################
# Create Dockerfile from template
# echo starting contianers...
# Arguments:
#   None
# Outputs:
#   None
#######################################
function create_dockerfile {
    echo "Starting containers:"
    for CONTAINER in $CONTAINERS; do
        echo "  - $CONTAINER"
    done
}
#######################################
# Build all images from compose file
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function build_containers() {
    echo "Ensuring all containers are built."
    docker compose build --pull --parallel $CONTAINERS
}

#######################################
# Bring up containers from compose file
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function boot_containers() {
    echo "Booting containers."
    docker compose up --detach $CONTAINERS
}


#######################################
# Compare 2 semver variables
# Globals:
#   None
# Arguments:
#   version 1, version 2
# Outputs:
#   0 for equal, 1 for >, 2 for <
#######################################
function compare_ver(){
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}



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
				if [ -d "/mnt/wsl" ]; then
					PLATFORM=WINDOWS 
				else
					PLATFORM=LINUX
				fi 
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

