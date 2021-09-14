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

            # Wait for the DB to accept connections
			sleep 20

			until nc -z -v -w30 localhost ${DB_PORT} 2>&1 | grep -E "${DB_PORT}.+(open|succeeded!)$"; do
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
        echo -n "Waiting for WordPress to start in container $CONTAINER..."

		docker exec -ti "$CONTAINER" /bin/bash -c 'until [[ -f .htaccess ]]; do echo -n "."; sleep 1; done'
		docker exec -ti "$CONTAINER" /bin/bash -c 'wp --allow-root core is-installed 2>/dev/null'
		
		# $? is the exit code of the previous command.
        # We check if WP is installed, if it is not, it returns with exit code 1
        IS_INSTALLED=$?

        if [[ $IS_INSTALLED == 1 ]]; then
            echo "WordPress has NOT been configured.".		
			echo "Installing WordPress in container $CONTAINER..."

			docker exec -ti "$CONTAINER" /bin/bash -c 'cp /tmp/wp-config.php /var/www/html/wp-config.php; chown www-data: /var/www/html/wp-config.php; chmod +w /var/www/html/wp-config.php'
			# Change the wordpress table_prefix to 5 random characters
			RANDOM_DBTABLE_PREFIX=$(LC_CTYPE=C tr -dc a-z < /dev/urandom | head -c 5)
			docker exec -ti "$CONTAINER" /bin/bash -c "sed -i \"s#table_prefix = 'wp_'#table_prefix = '"$RANDOM_DBTABLE_PREFIX"_'#\" /var/www/html/wp-config.php"

            docker exec -ti "$CONTAINER" /bin/bash -c 'mkdir -p /var/www/.wp-cli/packages; chown -R www-data: /var/www/.wp-cli;'
            docker exec --user "$USER_ID" -ti "$CONTAINER" /bin/bash -c 'php -d memory_limit=512M "$(which wp)" package install git@github.com:yoast/wp-cli-faker.git'
            docker cp ./seeds "$CONTAINER":/seeds

            docker exec --user "$USER_ID" -ti "$CONTAINER" /seeds/"$CONTAINER"-seed.sh
        fi

        echo 'WordPress is installed.'
    done
}
#######################################
# Quit Docker Desktop App
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function quit_docker_app() {
	osascript -e 'quit app "Docker"'
}

#######################################
# Start Docker Desktop App
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function start_docker_app() {
	open --background -a Docker
	echo "Giving docker time to start..."
	until docker info 2> /dev/null 1> /dev/null; do
		sleep 2
		echo "Giving docker time to start..."
	done
}

#######################################
# Synchronizes Docker & Mac Clock to prevent issues
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
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
	if [[ "$OSTYPE" == linux-gnu ]]; then
		:
	else
		synchronize_clocks
	fi
}