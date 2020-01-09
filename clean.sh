#!/bin/bash
docker-compose down --volumes --remove-orphans
docker-compose stop
docker-compose rm -fv
rm -rf wordpress
git checkout -- wordpress/.gitkeep
