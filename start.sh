#!/bin/bash
source ./config/config.sh
URL="http://$HOST"

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

echo "Fixing user permissions..."
docker exec -ti local-wordpress /bin/bash -c "usermod -u $(id -u) www-data"
docker exec -ti local-wordpress /bin/bash -c "groupmod -g $(id -g) www-data"
docker restart local-wordpress

echo "Waiting for containers to boot..."
while [ "$BOOTED" != "true"  ]; do
	if curl -I $URL 2>/dev/null | grep -q -e "HTTP/1.1 200 OK" -e "HTTP/1.1 302 Found"; then
		BOOTED=true
	else
		sleep 2
		echo "Waiting for containers to boot..."
	fi
done

open $URL 2>/dev/null || x-www-browser $URL

while [ "$STOPPING" != 'true' ]; do
	CLOCK_SOURCE=`docker exec -ti local-wordpress /bin/bash -c 'cat /sys/devices/system/clocksource/clocksource0/current_clocksource'| tr -d '[:space:]'`
	if [[ "$CLOCK_SOURCE" != 'tsc' && "$STOPPING" != 'true' ]]; then
		echo "Restarting docker now to fix out-of-sync hardware clock!"
		docker ps -q | xargs -L1 docker stop
		osascript -e 'quit app "Docker"'
		open --background -a Docker
		echo "Giving docker time to start..."
		until docker info 2> /dev/null 1> /dev/null; do
			sleep 2
			echo "Giving docker time to start..."
		done
		echo "Docker is up and running again! Booting containers!"
		docker-compose up &
		PROCESS=$!
	fi
	sleep 5
done
