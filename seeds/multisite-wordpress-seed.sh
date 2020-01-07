#!/bin/bash
source "${BASH_SOURCE%/*}/core-install.sh"
wp core multisite-convert
wp super-admin add admin
wp site create --slug=site2
