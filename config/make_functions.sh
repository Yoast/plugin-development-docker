#!/bin/bash

function verify_hostfile () {
	local hostfile=$1
	if [ -f "$hostfile" ]; then
		echo "Found host file at ${hosts_candidate}"            
		return;
	else
		echo "host file not found!"
	   exit 1
	fi
}

function check_hosts_newline () {
    hosts_lastchar=$(tail -c 1 $hostfile)
    [[ "$hosts_lastchar" != "" ]] && echo '' | sudo tee -a $hostfile
}

function change_hostfile () {
    local URL=$1
	echo "Checking hostfile entry for: ${URL}... "

    if grep -q -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" $hostfile; then
        if grep -q -E "^127\.0\.0\.1[[:space:]]+$URL" $hostfile; then
            echo "OK"
        else
            echo "Found this entry:"
            grep -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" $hostfile;
            select yn in "Change it to use docker" "Leave it"; do
                case $yn in
                    "Change it to use docker" )
                        echo "Need sudo to edit hostfile"
                        check_hosts_newline
                        grep -v -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" $hostfile | sudo tee $hostfile > /dev/null
                        echo "127.0.0.1 $URL" | sudo tee -a $hostfile > /dev/null
                        break
                    ;;
                    "Leave it" ) break;;
                esac
            done
        fi
    else
        echo "Adding, need sudo"
        check_hosts_newline
        echo "127.0.0.1       $URL" | sudo tee -a $hostfile > /dev/null
    fi
}