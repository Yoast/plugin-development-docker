#!/bin/bash

# Prevent script from running as root (root-related actions will prompt for the needed credentials)
[[ $EUID -eq 0 ]] && echo "Do not run with sudo / as root." && exit 1

# Remove corrupt php.ini folder, if existing.
[[ -d './config/php.ini' ]] && rm -rf './config/php.ini'

cp -n config/php.ini.default config/php.ini
cp -n config/config.sh.default config/config.sh
chmod u+x config/config.sh

hostfile = ''
platform = APPLE

function find_platform () {
    # try windows first, mac second; add future platforms here.
    # check the most unique identifier first to make sure there aren't any conflicts;
	# e.g. windows git bash also has an /etc/hosts file, so the fact that file exists only means something if C:/Windows does NOT exist.
    index = 0
    for hosts_candidate in "C:/windows/system32/drivers/etc/hosts" "/etc/hosts"; do
        echo -n "looking for hostfile at "$hosts_candidate
        if [ -f "$hosts_candidate" ]; then
            #file exists, assign hostfile in outer function to current value
            echo -n "Found host file at ${hosts_candidate}" 
            
            hostfile=$hosts_candidate
            [[ "$index" == 0 ]] && $platform = APPLE
            [[ "$index" == 1 ]] && $platform = WINDOWS

            return;
        fi
        index = 1 + $index
    done

    echo "host file not found!"
    exit 1
}

find_platform

if [ "$platform" == APPLE ]; then 
	source ./make_mac.sh
elif [ "$platform" == WINDOWS ]; then 
	source /.make_win.sh
fi
