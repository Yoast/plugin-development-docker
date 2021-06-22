#!/bin/bash
echo "***Configuring Wordpress***"
echo "$(set -x && wp core install --path=/var/www/html --url=${SITE_URL} --title=${SITE_TITLE} --admin_user=${ADMIN_USERNAME} --admin_password=${ADMIN_PASSWORD} --admin_email=${ADMIN_EMAIL})"
wp rewrite structure "%postname%/"
echo "$(wp rewrite flush --hard)"
echo "***Installing Wordpress plugins***"
echo "$(wp plugin install debug-bar --activate)"
echo "$(wp plugin install query-monitor --activate)"