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
function install_wordpress() {
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
            if curl -kI "$URL" 2>/dev/null | grep -q -e "HTTP/1.1 200 OK" -e "HTTP/1.1 302 Found" -e "HTTP/2 200" -e "HTTP/1.1 301 Moved Permanently"; then
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
