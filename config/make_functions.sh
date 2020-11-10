#!/bin/bash

function verify_hostfile () {
	local hostfile=$1
	if [ ! -f "$hostfile" ]; then
		echo "host file not found at ${hosts_candidate} - aborting..."            
		exit 1
	fi
}

function check_hosts_newline () {
    hosts_lastchar=$(tail -c 1 $hostfile)
    [[ "$hosts_lastchar" != "" ]] && echo '' | sudo tee -a $hostfile
}

function change_hostfile () {
    local path_to_hostfile=$1
	local URL=$2
	echo -n "Checking hostfile entry for: ${URL}... "

    if grep -q -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" $path_to_hostfile; then
        if grep -q -E "^127\.0\.0\.1[[:space:]]+$URL" $path_to_hostfile; then
            echo "OK"
        else
            echo "Found this entry:"
            grep -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" $path_to_hostfile;
            select yn in "Change it to use docker" "Leave it"; do
                case $yn in
                    "Change it to use docker" )
                        echo "Need sudo to edit path_to_hostfile"
                        check_hosts_newline
                        grep -v -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" $path_to_hostfile | sudo tee $path_to_hostfile > /dev/null
                        echo "127.0.0.1 $URL" | sudo tee -a $path_to_hostfile > /dev/null
                        break
                    ;;
                    "Leave it" ) break;;
                esac
            done
        fi
    else
        echo "Adding, need sudo"
        check_hosts_newline
        echo "127.0.0.1       $URL" | sudo tee -a $path_to_hostfile > /dev/null
    fi
}

function platform_independent_make() {
	local path_to_hostfile=$1
	verify_hostfile $path_to_hostfile

	change_hostfile $path_to_hostfile ${BASIC_HOST:-basic.wordpress.test}
	change_hostfile $path_to_hostfile ${WOOCOMMERCE_HOST:-woocommerce.wordpress.test}
	change_hostfile $path_to_hostfile ${MULTISITE_HOST:-multisite.wordpress.test}
	change_hostfile $path_to_hostfile test.${MULTISITE_HOST:-multisite.wordpress.test}
	change_hostfile $path_to_hostfile translate.${MULTISITE_HOST:-multisite.wordpress.test}
	change_hostfile $path_to_hostfile ${STANDALONE_HOST:-standalone.wordpress.test}
	change_hostfile $path_to_hostfile ${BASIC_DATABASE_HOST:-basic-database.wordpress.test}
	change_hostfile $path_to_hostfile ${WOOCOMMERCE_DATABASE_HOST:-woocommerce-database.wordpress.test}
	change_hostfile $path_to_hostfile ${MULTISITE_DATABASE_HOST:-multisite-database.wordpress.test}
	change_hostfile $path_to_hostfile ${STANDALONE_DATABASE_HOST:-standalone-database.wordpress.test}
}

function create_self_signed_cert() {
    if [[ ! -f './config/certs/wordpress.test.key' ]]; then 
        openssl req -newkey rsa:2048 -nodes -subj '/C=NL/ST=Gelderland/L=Wijchen/O=Yoast/OU=Development/CN=*.wordpress.test' -keyout ./config/certs/wordpress.test.key -x509 -days 730 -out ./config/certs/wordpress.test.crt
    fi

    for domain in ${BASIC_HOST} ${WOOCOMMERCE_HOST} ${MULTISITE_HOST} ${STANDALONE_HOST}; do
        if [[ $domain != '' ]]; then
            openssl req -newkey rsa:2048 -nodes -subj "/C=NL/ST=Gelderland/L=Wijchen/O=Yoast/OU=Development/CN=${domain}" -keyout ./config/certs/${domain}.key -x509 -days 730 -out ./config/certs/${domain}.crt
        fi
    done
}
