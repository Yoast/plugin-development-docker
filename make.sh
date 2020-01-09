#!/bin/bash
cp -n config/php.ini.default config/php.ini
cp -n config/config.sh.default config/config.sh
chmod u+x config/config.sh

change_hostfile () {
    local URL=$1
    echo "checking hostfile entry for: $URL"

    if grep -q -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" /etc/hosts; then
        if grep -q -E "^127\.0\.0\.1[[:space:]]+$URL" /etc/hosts; then
            echo OK
        else
            echo "Found this entry for: $URL"
            grep -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" /etc/hosts;
            select yn in "Change it to use docker" "Leave it"; do
                case $yn in
                    "Change it to use docker" )
                        echo need sudo to edit hostfile
                        grep -v -E "^([0-9]{1,3}[\.]){3}[0-9]{1,3}[[:space:]]+$URL" /etc/hosts | sudo tee /etc/hosts > /dev/null
                        echo "127.0.0.1 $URL" | sudo tee -a /etc/hosts > /dev/null
                        break
                    ;;
                    "Leave it" ) break;;
                esac
            done
        fi
    else
        echo adding $URL to hostfile need sudo
        echo "127.0.0.1       $URL" | sudo tee -a /etc/hosts > /dev/null
    fi
}

source ./config/config.sh

change_hostfile ${BASIC_HOST:-basic.wordpress.test}
change_hostfile ${WOOCOMMERCE_HOST:-woocomerce.wordpress.test}
change_hostfile ${MULTISITE_HOST:-multisite.wordpress.test}
change_hostfile ${BASIC_DATABASE_HOST:-basic-database.wordpress.test}
change_hostfile ${WOOCOMMERCE_DATABASE_HOST:-woocommerce-database.wordpress.test}
change_hostfile ${MULTISITE_DATABASE_HOST:-multisite-database.wordpress.test}
