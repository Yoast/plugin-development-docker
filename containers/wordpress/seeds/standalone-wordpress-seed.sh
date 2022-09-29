#!/bin/bash
echo "$(wp core install --url=https://${SITE_URL} --title=${SITE_TITLE} --admin_user=${ADMIN_USERNAME} --admin_password=${ADMIN_PASSWORD} --admin_email=${ADMIN_EMAIL})"
wp rewrite structure "%postname%/"
echo "$(wp rewrite flush --hard)"
