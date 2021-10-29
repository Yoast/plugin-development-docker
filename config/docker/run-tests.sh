#!/bin/bash

PLUGIN_TARGET_PATH=/tmp/wordpress/src/wp-content/plugins/wordpress-seo
PLUGIN_SOURCE_PATH=/var/www/html/wp-content/plugins/wordpress-seo

SCRIPT_DIR=$( dirname -- "$0" )

source $SCRIPT_DIR/pre-run-tests.sh

cd $PLUGIN_TARGET_PATH

echo Running PHPUnit...
#/tmp/phive/phpunit
/tmp/phive/phpunit --configuration phpunit-integration.xml.dist
echo Done!
cd -

exit 0
