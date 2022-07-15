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
        echo -n "Waiting for WordPress and setup to finish in container $CONTAINER..."
		docker exec -ti "$CONTAINER" /bin/bash -c 'until [[ -f /tmp/done ]]; do echo -n "."; sleep 1; done'
        echo 'WordPress is installed.'
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
