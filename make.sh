#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

platform=APPLE

function prepare_files() {
	# Remove corrupt php.ini folder, if existing.
	[[ -d './config/php.ini' ]] && rm -rf './config/php.ini'

	cp  config/php.ini.default config/php.ini
	cp  config/config.sh.default config/config.sh
}

function find_platform () {
    # try windows first, mac second; add future platforms here.
    # check the most unique identifier first to make sure there aren't any conflicts;
	# e.g. windows git bash also has an /etc/hosts file, so the fact that file exists only means something if C:/Windows does NOT exist.
    local index=0
    for hosts_candidate in "C:/windows/system32/drivers/etc/hosts" "/etc/hosts"; do
        echo "looking for hostfile at ${hosts_candidate}"
        if [ -f "$hosts_candidate" ]; then
            #file exists, assign hostfile in outer function to current value
            echo  "Found host file at ${hosts_candidate}" 
            
            [[ $index == 0 ]] && platform=WINDOWS
            [[ $index == 1 ]] && platform=APPLE

            return;
        fi
        index=1 + $index
    done

    echo  "host file not found!"
    exit 1
}

prepare_files
find_platform

if [ "$platform" == WINDOWS ]; then 
	source config/make_win.sh
else
	# supports mac and ubuntu
	source config/make_mac.sh
fi

#this function is defined in either make_win.sh or make_mac.sh
echo "Running make script for ${platform}"
platform_make