#!/bin/bash
echo "$(wp core multisite-install --url=https://${SITE_URL} --title=${SITE_TITLE} --admin_user=${ADMIN_USERNAME} --admin_password=${ADMIN_PASSWORD} --admin_email=${ADMIN_EMAIL})"
wp rewrite structure "%postname%/"
echo "$(wp rewrite flush --hard)"
echo "$(wp plugin install debug-bar --activate)"
echo "$(wp plugin install query-monitor --activate)"
wp super-admin add admin
echo "$(wp site create --slug=site2)"
wp faker core content
echo "$(wp faker core content --url=${SITE_URL}/site2)"
