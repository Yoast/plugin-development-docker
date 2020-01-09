#!/bin/bash
until mountpoint -q /var/www/html; do
    sleep 1
done

until mountpoint -q /var/www/html/wp-content/plugins; do
    sleep 1
done

until mountpoint -q /var/www/html/wp-config.php; do
    sleep 1
done

exec /usr/local/bin/docker-entrypoint.sh "$@"
