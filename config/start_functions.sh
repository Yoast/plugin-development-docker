#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1


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
