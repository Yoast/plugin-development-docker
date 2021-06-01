#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

source config/config.sh
source scripts/make_functions.sh

hostfile=C:/windows/system32/drivers/etc/hosts

function platform_make() {
	platform_independent_make $hostfile
}
