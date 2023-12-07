FROM wordpress:php8.1-apache
ARG UID=1000
ARG GID=1000
ARG SEED_FILE=basic-wordpress-seed.sh

RUN pecl install xdebug-3.1.6 && docker-php-ext-enable xdebug
RUN docker-php-ext-install pdo_mysql

RUN apt-get update && apt-get install -y zlib1g-dev 
RUN pecl install memcache
RUN pecl install redis
RUN docker-php-ext-enable memcache
RUN docker-php-ext-enable redis

RUN apt-get -y install default-mysql-client less

RUN curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Install a sendmail replacement which forwards mail to an SMTP server, so we can use Mailhog.
RUN if [ "$(uname -m)" = "aarch64" ] ; \ 
    then curl -sL https://github.com/evertiro/mhsendmail/releases/download/v0.2.0-M1/mhsendmail_linux_arm64 --output /usr/local/bin/mhsendmail ;\ 
    else curl -sL https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 --output /usr/local/bin/mhsendmail ; fi \
    && chmod +x /usr/local/bin/mhsendmail

# setup for correct user id and group id use same as user on local system in the container 
RUN usermod -u $UID www-data && groupmod -o -g $GID www-data \
    && mkdir -p /var/www/.wp-cli/packages \
    && mkdir -p /var/www/.composer/cache/vcs \
    && chown -R $UID:$GID /var/www

COPY ./containers/wordpress/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY ./containers/wordpress/seeds/$SEED_FILE /usr/local/bin/wordpress-seed.sh
COPY ./containers/wordpress/seeds/core-install.sh /usr/local/bin/core-install.sh
COPY ./containers/wordpress/wp-cli-faker.zip /tmp/wp-cli-faker.zip
# trust *.worpdress.test certificate
COPY ./config/certs/wordpress.test.crt /usr/local/share/ca-certificates/wordpress.test.crt
RUN update-ca-certificates

USER www-data
