#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

source config/config.sh
source config/make_functions.sh

hostfile=''

function platform_make() {

	verify_hostfile C:/windows/system32/drivers/etc/hosts

	change_hostfile ${BASIC_HOST:-basic.wordpress.test}
	change_hostfile ${WOOCOMMERCE_HOST:-woocommerce.wordpress.test}
	change_hostfile ${MULTISITE_HOST:-multisite.wordpress.test}
	change_hostfile test.${MULTISITE_HOST:-multisite.wordpress.test}
	change_hostfile translate.${MULTISITE_HOST:-multisite.wordpress.test}
	change_hostfile ${STANDALONE_HOST:-standalone.wordpress.test}
	change_hostfile ${BASIC_DATABASE_HOST:-basic-database.wordpress.test}
	change_hostfile ${WOOCOMMERCE_DATABASE_HOST:-woocommerce-database.wordpress.test}
	change_hostfile ${MULTISITE_DATABASE_HOST:-multisite-database.wordpress.test}
	change_hostfile ${STANDALONE_DATABASE_HOST:-standalone-database.wordpress.test}
}