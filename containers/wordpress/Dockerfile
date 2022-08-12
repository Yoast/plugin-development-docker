FROM wordpress:latest
ARG UID=1000
ARG GID=1000
ARG SEED_FILE=basic-wordpress-seed.sh

RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN docker-php-ext-install pdo_mysql

RUN apt-get update \
    && apt-get -y install default-mysql-client less

RUN curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN if [ "$(uname -m)" = "aarch64" ] ; \ 
    then curl -sL https://github.com/evertiro/mhsendmail/releases/download/v0.2.0-M1/mhsendmail_linux_arm64 --output /usr/local/bin/mhsendmail ;\ 
    else curl -sL https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 --output /usr/local/bin/mhsendmail ; fi \
    && chmod +x /usr/local/bin/mhsendmail

# setup for correct user id and group id use same as user on local system in the container 
RUN usermod -u $UID www-data && groupmod -o -g $GID www-data \
    && mkdir -p /var/www/.wp-cli/packages \
    && mkdir -p /var/www/.composer/cache/vcs \
    && mkdir -p /mnt/plugins \
    && chown -R $UID:$GID /var/www \
    && chown -R $UID:$GID /var/www 

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY ./seeds/$SEED_FILE /usr/local/bin/wordpress-seed.sh
COPY ./seeds/core-install.sh /usr/local/bin/core-install.sh

USER www-data
