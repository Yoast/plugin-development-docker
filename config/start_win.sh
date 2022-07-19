#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1



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
function check_kubernetes_node() {
	# Current Workaround to disable Kubernetes in Rancher Desktop
	kubectl config use-context rancher-desktop
    NODENAME=$(kubectl get node -o jsonpath="{.items[*].metadata.name}")
	if [[ -z "$NODENAME" ]]; then
        echo "Lima node is not running, continuing..."
	else
        echo "Lima node is running, shutting it down..."
		kubectl delete node "$NODENAME"
	fi
}
