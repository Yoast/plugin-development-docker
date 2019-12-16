#!/bin/bash
SCRIPTS_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

cd "$SCRIPTS_PATH/../docker"

trap stop_docker INT
function stop_docker {
    STOPPING=true
	wait $PROCESS
	exit
}

echo "Ensuring all containers are built"
docker-compose up --no-start

echo "Booting containers"
docker-compose up &
PROCESS=$!
sleep 2

open "http://local.wordpress.test" 2>/dev/null || x-www-browser "http://local.wordpress.test"

while true; do
	CLOCK_SOURCE=`docker exec -ti local-wordpress /bin/bash -c 'cat /sys/devices/system/clocksource/clocksource0/current_clocksource'| tr -d '[:space:]'`
	if [[ "$CLOCK_SOURCE" != 'tsc' && "$STOPPING" != "true" ]]; then
		echo "Restarting docker now to fix out-of-sync hardware clock!"
		docker ps -q | xargs -L1 docker stop
		osascript -e 'quit app "Docker"'
		open --background -a Docker
		echo "Giving docker time to start..."
		until docker info 2> /dev/null 1> /dev/null; do
			sleep 1
		done
		echo "Docker is up and running again! Booting containers!"
		docker-compose up &
		PROCESS=$!
	fi
	sleep 5
done
