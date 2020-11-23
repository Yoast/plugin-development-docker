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
        echo -n "Waiting for WordPress to start in container $CONTAINER..."
		docker exec -i "$CONTAINER" //bin/bash -c 'until [[ -f .htaccess ]]; do echo -n "."; sleep 1; done'
		echo "OK"
		
		#-Xallow-non-tty tells winpty to route output of non-tty ming64 bash to stdout so we can read it
		local IS_INSTALLED=$(winpty -Xallow-non-tty docker exec -i basic-wordpress //bin/bash -c 'wp --allow-root core' | grep "is not installed" -o)
        
		if [[ $IS_INSTALLED == 'is not installed' ]]; then
            echo "WordPress has NOT been configured.".
			echo "Installing WordPress in container $CONTAINER..."

            docker exec -ti "$CONTAINER" //bin/bash -c 'ln -sf /tmp/wp-config.php /var/www/html/wp-config.php'

            docker exec -i "$CONTAINER" //bin/bash -c 'mkdir -p /var/www/.wp-cli/packages; chown -R www-data: /var/www/.wp-cli;'
            docker exec -i "$CONTAINER" //bin/bash -c 'chown www-data: /var/www/html/wp-content'
            docker exec --user "$USER_ID" -i "$CONTAINER" //bin/bash -c 'php -d memory_limit=512M "$(which wp)" package install git@github.com:yoast/wp-cli-faker.git'
            
			docker cp ./seeds "$CONTAINER":/seeds						       		
            docker exec --user "$USER_ID" -i "$CONTAINER" //seeds/"$CONTAINER"-seed.sh
		fi

        echo 'WordPress is installed.'
    done
}

function platform_tasks() {
	# add repetitive platform maintenance here
	:
}
