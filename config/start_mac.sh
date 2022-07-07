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

		docker exec -ti "$CONTAINER" /bin/bash -c 'until [[ -f .htaccess ]]; do echo -n "."; sleep 1; done'
		docker exec -ti "$CONTAINER" /bin/bash -c 'until [[ -f wp-config.php ]]; do echo -n "."; sleep 1; done'
		
		docker exec -ti "$CONTAINER" /bin/bash -c 'wp core is-installed 2>/dev/null'
	    # $? is the exit code of the previous command.
        # We check if WP is installed, if it is not, it returns with exit code 1
        IS_INSTALLED=$?

        if [[ $IS_INSTALLED == 1 ]]; then
            docker exec -ti "$CONTAINER" /bin/bash -c 'mkdir -p /var/www/.composer/cache/vcs'
			echo "WordPress has NOT been configured.".		
			echo "Installing WordPress in container $CONTAINER..."

			docker exec -ti "$CONTAINER" /bin/bash -c 'ln -sf /tmp/wp-config.php /var/www/html/wp-config.php'
            docker exec -ti "$CONTAINER" /bin/bash -c 'mkdir -p /var/www/.wp-cli/packages; chown -R www-data: /var/www/.wp-cli;'
            docker exec --user "$USER_ID" -ti "$CONTAINER" /bin/bash -c 'php -d memory_limit=512M "$(which wp)" package install git@github.com:yoast/wp-cli-faker.git'
            docker cp ./seeds "$CONTAINER":/seeds

            docker exec --user "$USER_ID" -ti "$CONTAINER" /seeds/"$CONTAINER"-seed.sh
        fi

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
