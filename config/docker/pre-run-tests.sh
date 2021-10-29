#!/bin/bash

mkdir -p $PLUGIN_TARGET_PATH

# Copy over the latest code to the test directory.
rsync -r $PLUGIN_SOURCE_PATH/ $PLUGIN_TARGET_PATH --exclude=node_modules --exclude=vendor

cd $PLUGIN_TARGET_PATH

# Assuming PHP 8.0 for now.
composer install --no-interaction --ignore-platform-reqs

mkdir -p src/generated/assets
echo "<?php return [ 'post-edit-' . ( new WPSEO_Admin_Asset_Manager() )->flatten_version( WPSEO_VERSION ) . '.js' => [ 'dependencies' => [] ] ];" > src/generated/assets/plugin.php
echo "<?php return [];" > src/generated/assets/externals.php
echo "<?php return [];" > src/generated/assets/languages.php

mysql -e "CREATE DATABASE IF NOT EXISTS wordpress_tests;" -uroot -prootpassword -hwordpress-basic-database

phive --no-progress install phpunit --target /tmp/phive --trust-gpg-keys 4AA394086372C20A
