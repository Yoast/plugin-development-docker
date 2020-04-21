#!/bin/bash

# Get all the running containers and store the amount
running_containers=$(docker ps --filter "ancestor=wordpress" --filter "label=com.docker.compose.project.working_dir=$(pwd)" --format "{{.Names}}")
count_containers=$(echo "$running_containers" | wc -l)

# Check if the first argument is a docker container...
if [[ $(echo "$running_containers" | grep $1) ]]; then
    CONTAINER=$1
    shift
# ... if not, see if only one container is running...
elif [[ "$((count_containers))" == 1 ]]; then
    CONTAINER=$(echo "$running_containers" | head -n1 | cut -d " " -f 1)
# ...if not, multiple containers are running and no valid container is passed. We exit
elif [[ "$((count_containers))" > 1 ]]; then
    echo ""
    echo "Multiple containers are running, but no valid container name was given."
    echo "Please run your command as \"wp <container name> command\" and choose one of the following running containers:"
    echo "$running_containers"
    exit 1
fi

# Execute the WP-CLI command, capture & display the output and errors
wp_result=$(docker exec -ti --user www-data $CONTAINER wp $@ 2>&1)
echo $wp_result

# If the error looks like the first argument to WP-CLI is wrong, hint that it might be a mistyped containername
[[ $(echo $wp_result | grep 'not a registered wp command.') ]] && echo -e "\nMaybe you got the Docker container name wrong.\nNote that you don't need a container name if only one container is running.\nThis container is running:\n${running_containers}" && exit 1
