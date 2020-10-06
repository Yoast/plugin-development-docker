#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

function await_database_connections() {
    if ! [ "$DOCKER_DB_NO_WAIT" ]; then
        echo "Waiting for databases to boot."
        for CONTAINER in $CONTAINERS; do
            DB_PORT_VAR="DB_PORT_${CONTAINER//-/_}"
            DB_PORT=${!DB_PORT_VAR}
                        
			until nc -z -v -w30 localhost ${DB_PORT} 2>&1 | grep "${DB_PORT}"; do
				echo "Waiting until database accepts connections at port $DB_PORT..."
				sleep 2
			done
        done
    fi
}

function install_wordpress() {
    for CONTAINER in $CONTAINERS; do
        echo -n "Waiting for WordPress to start in container $CONTAINER..."

		docker exec -ti "$CONTAINER" /bin/bash -c 'until [[ -f .htaccess ]]; do echo -n "."; sleep 1; done'
		docker exec -ti "$CONTAINER" /bin/bash -c 'wp --allow-root core is-installed 2>/dev/null'
		
		# $? is the exit code of the previous command.
        # We check if WP is installed, if it is not, it returns with exit code 1
        IS_INSTALLED=$?

        if [[ $IS_INSTALLED == 1 ]]; then
            echo "WordPress has NOT been configured.".			
			echo "Installing WordPress in container $CONTAINER..."

            docker exec -ti "$CONTAINER" /bin/bash -c 'mkdir -p /var/www/.wp-cli/packages; chown -R www-data: /var/www/.wp-cli;'
            docker exec --user "$USER_ID" -ti "$CONTAINER" /bin/bash -c 'php -d memory_limit=512M "$(which wp)" package install git@github.com:Yoast/wp-cli-faker.git'
            docker cp ./seeds "$CONTAINER":/seeds

			chown u+w wp-content

            docker exec --user "$USER_ID" -ti "$CONTAINER" /seeds/"$CONTAINER"-seed.sh
        fi

        echo 'WordPress is installed.'
    done
}

function quit_docker_app() {
	osascript -e 'quit app "Docker"'
}

function start_docker_app() {
	open --background -a Docker
	echo "Giving docker time to start..."
	until docker info 2> /dev/null 1> /dev/null; do
		sleep 2
		echo "Giving docker time to start..."
	done
}

function synchronize_clocks() {
	CLOCK_SOURCE=$(docker exec -ti nginx-router-wordpress /bin/bash -c 'cat /sys/devices/system/clocksource/clocksource0/current_clocksource' | tr -d '[:space:]')
	if [[ "$CLOCK_SOURCE" != 'tsc' && "$STOPPING" != 'true' ]]; then
		echo "Restarting docker now to fix out-of-sync hardware clock!"
		docker ps -q | xargs -L1 docker stop
		
		quit_docker_app
		start_docker_app

		echo "Docker is up and running again! Booting containers!"
		boot_containers
	fi
}

function platform_tasks() {
	synchronize_clocks
}