#!/bin/bash



#######################################
# Install WordPress if not present
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
