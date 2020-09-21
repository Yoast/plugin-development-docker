#!/bin/bash
wp core multisite-install --url=${SITE_URL} --title=${SITE_TITLE} --admin_user=${ADMIN_USERNAME} --admin_password=${ADMIN_PASSWORD} --admin_email=${ADMIN_EMAIL}
wp rewrite structure "%postname%/"
wp rewrite flush --hard
wp plugin install debug-bar --activate
wp plugin install query-monitor --activate
wp super-admin add admin
wp site create --slug=site2
wp faker core content
wp faker core content --url=${SITE_URL}/site2