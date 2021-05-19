# qa-environment-docker

**!! This is not a production environment !!**

This is a fairly simple docker container to facilitate testing of WordPress & WordPress plugins.

This environment is currently only tested on Ubuntu and MacOS.

## Prerequisites

Mac users:

- [Docker Desktop](https://docs.docker.com/docker-for-mac/install/) includes everything you need.
  
Ubuntu users:

- [Docker Engine](https://docs.docker.com/engine/install/ubuntu/)
includes everything you need.

## Setting up the containers

### 1. run `./start.sh`

This will create and start your containers. You can visit your environment by visiting:

- `http://basic.wordpress.test`
- `http://local.wordpress.test`

### 2. Stopping and Starting the Environment

You can stop your environment by typing: `docker-compose down`

You can start your environment by typing: `docker-compose up`

You can start your environment without outputting logs by typing: `docker-compose up -d`

## Connecting to the Database

| Property | Value     |
| -------- | --------- |
| Host     | 127.0.0.1 |
| Username | wordpress |
| Password | wordpress |
| Database | wordpress |

The port differs based on the installation you're running.

| Site            | Port |
| --------------- | ---- |
| basic-wordpress | 1987 |
| local-wordpress | 1988 |

## Folder Structure

The following folders will be created when you start up the containers:

- **wordpress-local**: Contains the files & folders of local.wordpress.test
- **wordpress-basic**: Contains the files & folders of basic.wordpress.test
- **plugins-local**: Contains all the Plugins from local.wordpress.test
- **plugins-basic**: Contains all the Plugins from basic.wordpress.test
- **xdebug**: Contains the log file of xdebug
