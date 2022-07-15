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
	# Default rancher location, it may be different depending on the user deciding to install the app somewhere else.
    default_rancher_loc='/Applications/Rancher Desktop.app/Contents/Resources/resources/linux/rancher-desktop.appdata.xml'
    rancher_desktop_version=$(grep -E "release version=\".+?\"" "${default_rancher_loc}" | cut -d '"' -f 2)
    rancher_should_be="1.1.1"

    # Compare the versions and exit if the used version is too old.
    compare_ver $rancher_desktop_version $rancher_should_be
    if [[ $? = 2 ]]; then
        echo "Your Rancher Desktop version is outdated (${rancher_desktop_version}). Please update to at least ${rancher_should_be}"
        exit 1
    fi

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
