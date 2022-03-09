#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

#######################################
# Wait until DB is ready to accept connections
# Globals:
#   DOCKER_DB_NO_WAIT
#   CONTAINERS
# Arguments:
#   None
# Outputs:
#   None
#######################################
function await_database_connections() {
    if ! [ "$DOCKER_DB_NO_WAIT" ]; then
        echo "Waiting for databases to boot."
        for CONTAINER in $CONTAINERS; do
            DB_PORT_VAR="DB_PORT_${CONTAINER//-/_}"
            DB_PORT=${!DB_PORT_VAR}
                        
            until netstat -an | grep ${DB_PORT}; do
				echo "Waiting until database accepts connections at port $DB_PORT..."
				sleep 2
			done
        done
    fi
}

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
        docker exec --user root "$CONTAINER" bash -c 'chown www-data:www-data /var/xdebug/xdebug.log'
        echo -n "Waiting for WordPress to start in container $CONTAINER..."
		docker exec "$CONTAINER" bash -c 'until [[ -f .htaccess ]]; do echo -n "."; sleep 1; done'
		docker exec "$CONTAINER" bash -c 'until [[ -f wp-config.php ]]; do echo -n "."; sleep 1; done'
		
		docker exec "$CONTAINER" bash -c 'wp --allow-root core is-installed 2>/dev/null'
		echo "OK"

		#-Xallow-non-tty tells winpty to route output of non-tty ming64 bash to stdout so we can read it
        docker exec "$CONTAINER" bash -c 'mkdir -p /var/www/.wp-cli/packages; chown -R www-data: /var/www/.wp-cli;'
		IS_INSTALLED=$(docker exec "$CONTAINER" wp core is-installed --allow-root --path='/var/www/html' 2>&1)

		if [[ $IS_INSTALLED == *"This does not seem to be a WordPress installation"* ]]; then
            echo "WordPress has NOT been configured."
            sleep 20
			echo "Installing WordPress in container $CONTAINER..."
            docker exec "$CONTAINER" bash -c 'ln -sf /tmp/wp-config.php /var/www/html/wp-config.php'
            docker exec "$CONTAINER" bash -c 'chown www-data: /var/www/html/wp-content'
            docker exec "$CONTAINER" bash -c 'chown www-data: /var/www/html/wp-includes'
            docker exec --user "$USER_ID" "$CONTAINER" bash -c 'php -d memory_limit=512M "$(which wp)" package install git@github.com:yoast/wp-cli-faker.git'
            
			docker cp ./seeds "$CONTAINER":/seeds						       		
            docker exec --user "$USER_ID" "$CONTAINER" bash -c "source /seeds/$CONTAINER-seed.sh"
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
	# add repetitive platform maintenance here
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