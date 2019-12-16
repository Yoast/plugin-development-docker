#!/bin/bash
docker stop local-wordpress
docker stop local-wordpress-db

docker container prune
docker rmi local-wordperss

docker system prune
docker images rmi 
rm -rf ./data/mysql
rm -rf ./data/xdebug/*
git checkout -- ./data/xdebug/.gitkeep
