#!/bin/bash

echo "**Starting Cleanup**"
echo "**Shutting down Docker Containers**"
docker-compose down --rmi all -v

echo "**Removing Persistant Volumes**"
docker volume rm basic-database-data
docker volume rm local-database-data

echo "**Removing Local Files**"
rm -rf plugins-basic plugins-local wordpress-basic wordpress-local xdebug