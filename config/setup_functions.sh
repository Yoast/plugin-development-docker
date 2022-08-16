#!/bin/bash

#######################################
# Check if Hostfile is present 
# Globals:
#   None
# Arguments:
#   Path to Hostfile
# Outputs:
#   None
#######################################
function verify_hostfile () {
	local hostfile=$1
	if [ ! -f "$hostfile" ]; then
		echo "host file not found at ${hosts_candidate} - aborting..."            
		exit 1
	fi
}

#######################################
# If the hostfile does not have a empty line create one 
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function check_hosts_newline () {
    hosts_lastchar=$(tail -c 1 "$hostfile")
    [[ "$hosts_lastchar" != "" ]] && echo '' | sudo tee -a "$hostfile"
}

#######################################
# Add entry to hostfile
# Globals:
#   None
# Arguments:
#   path_to_hostfile
#   URL
# Outputs:
#   None
#######################################
function change_hostfile () {
    local path_to_hostfile=$1
	local URL=$2
	echo -n "Checking hostfile entry for: ${URL}... "

    if grep -q -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" "$path_to_hostfile"; then
        if grep -q -E "^127\.0\.0\.1[[:space:]]+$URL" "$path_to_hostfile"; then
            echo "OK"
        else
            echo "Found this entry:"
            grep -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" "$path_to_hostfile";
            select yn in "Change it to use docker" "Leave it"; do
                case $yn in
                    "Change it to use docker" )
                        echo "Need sudo to edit path_to_hostfile"
                        check_hosts_newline
                        grep -v -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" "$path_to_hostfile" | sudo tee "$path_to_hostfile" > /dev/null
                        echo "127.0.0.1 $URL" | sudo tee -a "$path_to_hostfile" > /dev/null
                        break
                    ;;
                    "Leave it" ) break;;
                esac
            done
        fi
    else
        echo "Adding, need sudo"
        check_hosts_newline
        echo "127.0.0.1       $URL" | sudo tee -a "$path_to_hostfile" > /dev/null
    fi
}

#######################################
# Regardless of platform, prepare the hostfile
# Globals:
#   None
# Arguments:
#   path_to_hostfile
# Outputs:
#   None
#######################################
function platform_independent_make() {
	local path_to_hostfile=$1
	verify_hostfile "$path_to_hostfile"

	change_hostfile "$path_to_hostfile" "${BASIC_HOST:-basic.wordpress.test}"
	change_hostfile "$path_to_hostfile" "${WOOCOMMERCE_HOST:-woocommerce.wordpress.test}"
	change_hostfile "$path_to_hostfile" "${MULTISITE_HOST:-multisite.wordpress.test}"
	change_hostfile "$path_to_hostfile" "test.${MULTISITE_HOST:-multisite.wordpress.test}"
	change_hostfile "$path_to_hostfile" "translate.${MULTISITE_HOST:-multisite.wordpress.test}"
	change_hostfile "$path_to_hostfile" "${STANDALONE_HOST:-standalone.wordpress.test}"
    change_hostfile "$path_to_hostfile" "${NIGHTLY_HOST:-nightly.wordpress.test}"
	change_hostfile "$path_to_hostfile" "${MULTISITEDOMAIN_HOST:-multisitedomain.wordpress.test}"
	change_hostfile "$path_to_hostfile" "test.${MULTISITEDOMAIN_HOST:-multisitedomain.wordpress.test}"
	change_hostfile "$path_to_hostfile" "translate.${MULTISITEDOMAIN_HOST:-multisitedomain.wordpress.test}"

    
}

#######################################
# Regardless of platform, make empty wp-config.php the files
# Globals:
#   None
# Arguments:
#   folder_name
# Outputs:
#   None
#######################################
function setup_wp-config.php() {
# clean up wp-config.php files
    # Remove corrupt wp-config.php folder, if existing.
    [[ -d ./config/$1/wp-config.php ]] && rm -rf ./config/$1/wp-config.php
    #setup empyy file is not already there
    [[ ! -f ./config/$1/wp-config.php ]] && mkdir -p ./config/$1/  && touch ./config/$1/wp-config.php && echo "setup clean wp-config.php for $1"

}


#######################################
# Regardless of platform, prepare the files
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################

function prepare_files() {
	# Remove corrupt php.ini folder, if existing.
	[[ -d ./config/php.ini ]] && rm -rf ./config/php.ini
	
    [[ ! -f ./config/php.ini ]] && cp  ./config/php.ini.default ./config/php.ini
    
	# Set environment variable for the Wordpress DB Table Prefix. and UID and GUI neede for file sysyem access on host system
	# Save this in a file so it is not random every boot (clean.sh removes this file).
	if [ ! -f .env ]; then
  		WORDPRESS_TABLE_PREFIX="$(LC_ALL=C tr -dc a-z < /dev/urandom | head -c 5 | xargs)_"  
  		cat .env.default | sed -e "s/UID=.*/UID=$(id -u)/" | sed -e "s/GID=.*/GID=$(id -g)/" | sed -e "s/WORDPRESS_TABLE_PREFIX=.*/WORDPRESS_TABLE_PREFIX=$WORDPRESS_TABLE_PREFIX/"  > .env
  		echo "WP table prefix: $WORDPRESS_TABLE_PREFIX"
	fi
    for name in basic woocommerce nightly multisite multisitedomain standalone
    do 
        setup_wp-config.php $name
    done
}
