FROM wordpress:latest
ARG UID=1000
ARG GID=1000

RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN docker-php-ext-install pdo_mysql

RUN apt-get update \
    && apt-get -y install default-mysql-client less

RUN curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN curl -sLO https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 \
    && chmod +x mhsendmail_linux_amd64 \
    && mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail

# setup for correct user id and group id use same as user on local system in the container 
RUN usermod -u $UID www-data && groupmod -o -g $GID www-data && chown -R www-data:www-data /var/www 

USER www-data
