#!/bin/bash

source config/functions.sh

USER_ID=$(id -u)
GROUP_ID=$(id -g)
DOCKERFILE='./containers/wordpress/Dockerfile'
hostfile=/etc/hosts

sed -i -e "s/\$UID/${USER_ID}/g" "$DOCKERFILE"
sed -i -e "s/\$GID/${GROUP_ID}/g" "$DOCKERFILE"

platform_independent_make $hostfile

docker-compose up -d

sleep 10

echo "***Installing Basic Wordpress***"
docker exec basic-wordpress wp core install --title=Basic --admin_user=wordpress --admin_email=test@wordpress.test --admin_password=wordpress --url=http://basic.wordpress.test --allow-root --path=/var/www/html
docker exec basic-wordpress wp rewrite structure "%postname%/" --allow-root
docker exec basic-wordpress wp rewrite flush --hard --allow-root
echo "***Installing Wordpress plugins for Basic***"
docker exec basic-wordpress wp plugin install debug-bar --activate --allow-root
docker exec basic-wordpress wp plugin install query-monitor --activate --allow-root

echo "***Installing Local Wordpress***"
docker exec local-wordpress wp core install --title=Local --admin_user=wordpress --admin_email=test@wordpress.test --admin_password=wordpress --url=http://local.wordpress.test --allow-root --path=/var/www/html
docker exec local-wordpress wp rewrite structure "%postname%/" --allow-root
docker exec local-wordpress wp rewrite flush --hard --allow-root
echo "***Installing Wordpress plugins for Local***"
docker exec local-wordpress wp plugin install debug-bar --activate --allow-root
docker exec local-wordpress wp plugin install query-monitor --activate --allow-root

echo "***Setting correct permissions***"
docker exec basic-wordpress chmod -R 777 /var/www/html
docker exec local-wordpress chmod -R 777 /var/www/html

docker exec basic-wordpress chmod -R 777 /var/xdebug
docker exec local-wordpress chmod -R 777 /var/xdebug

echo "*****************************************************"
echo "*            WordPress now running on:              *"
echo "*           http://basic.wordpress.test             *"
echo "*           http://local.wordpress.test             *"
echo "*                                                   *"
echo "*****************************************************"