#!/bin/bash
source "${BASH_SOURCE%/*}/core-install.sh"
wp plugin install woocommerce --activate
wp plugin install woocommerce-admin --activate