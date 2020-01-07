#!/bin/bash
docker-compose down --volumes --remove-orphans
rm -rf ./data/xdebug/*
git checkout -- ./data/xdebug/.gitkeep
