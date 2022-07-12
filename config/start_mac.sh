#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1


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
        echo -n "Waiting for WordPress to start in container $CONTAINER..."
		docker exec -ti "$CONTAINER" /bin/bash -c 'until [[ -f /tmp/done ]]; do echo -n "."; sleep 1; done'
        echo 'WordPress is installed.'
    done
}

#######################################
# Function that groups tasks depending on platform
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function platform_tasks() {
	:
}

#######################################
# Check if Kubernetes is running
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function check_lima_node() {
	# Current Workaround to disable Kubernetes in Rancher Desktop
	kubectl config use-context rancher-desktop
	NODES=$(kubectl get nodes | grep -o "lima-rancher-desktop" || true)
	if [[ "$NODES" == 'lima-rancher-desktop' ]]; then
		echo "Lima node is running, shutting it down..."
		kubectl delete node lima-rancher-desktop
	else
		echo "Lima node is not running, continuing..."
	fi
}
