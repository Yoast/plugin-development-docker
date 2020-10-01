#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

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

function install_wordpress() {
    for CONTAINER in $CONTAINERS; do
        echo -n "Checking if WordPress is installed in $CONTAINER..."

		docker exec -i "$CONTAINER" //bin/bash -c 'until [[ -f .htaccess ]]; do sleep 1; done'
		echo -n "step 1..."
		docker exec -i "$CONTAINER" //bin/bash -c 'wp --allow-root core is-installed 2>/dev/null'
		echo "step 2."
		
		# $? is the exit code of the previous command.
        # We check if WP is installed, if it is not, it returns with exit code 1
        IS_INSTALLED=$?
		
        if [[ $IS_INSTALLED == 1 ]]; then
            echo "Installing WordPress for $CONTAINER..."

            docker exec -i "$CONTAINER" //bin/bash -c 'mkdir -p /var/www/.wp-cli/packages; chown -R www-data: /var/www/.wp-cli;'
            docker exec --user "$USER_ID" -i "$CONTAINER" //bin/bash -c 'php -d memory_limit=512M "$(which wp)" package install git@github.com:Yoast/wp-cli-faker.git'
            
			docker cp ./seeds "$CONTAINER":/seeds						
			docker exec -i "$CONTAINER" //bin/bash -c 'chmod u+w //wordpress/upload'            		
            docker exec --user "$USER_ID" -i "$CONTAINER" //seeds/"$CONTAINER"-seed.sh
        fi

        echo 'WordPress is installed.'
    done
}

function platform_tasks() {
	# add repetitive platform maintenance here
	:
}
