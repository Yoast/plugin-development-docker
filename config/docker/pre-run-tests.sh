#!/bin/bash

# Plugin could be supplied as argument.

# Copy over the latest code to the test directory.
rsync /var/www/html/wp-content/plugins/wordpress-seo /tmp/wordpress/src/wp-content/plugins/wordpress-seo --exclude=/var/www/html/wp-content/plugins/wordpress-seo/node_modules --exclude=/var/www/html/wp-content/plugins/wordpress-seo/vendor

cd /var/www/html/wp-content/plugins/wordpress-seo

# Assuming PHP 8.0 for now.
composer install --no-interaction --ignore-platform-reqs --no-scripts

mkdir -p src/generated/assets
echo "<?php return [ 'post-edit-' . ( new WPSEO_Admin_Asset_Manager() )->flatten_version( WPSEO_VERSION ) . '.js' => [ 'dependencies' => [] ] ];" > src/generated/assets/plugin.php
echo "<?php return [];" > src/generated/assets/externals.php
echo "<?php return [];" > src/generated/assets/languages.php

mysql -e "CREATE DATABASE IF NOT EXISTS wordpress_tests;" -uroot -prootpassword -hwordpress-basic-database
