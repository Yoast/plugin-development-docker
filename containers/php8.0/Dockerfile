FROM php:8.0-apache

RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
RUN docker-php-ext-install pdo_mysql

RUN apt update
RUN apt install rsync -y
RUN apt install git -y

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN git clone --depth=1 --branch="5.8.1" git://develop.git.wordpress.org/ /tmp/wordpress

RUN cp /tmp/wordpress/wp-tests-config-sample.php /tmp/wordpress/wp-tests-config.php
RUN sed -i "s/youremptytestdbnamehere/wordpress_tests/" /tmp/wordpress/wp-tests-config.php
RUN sed -i "s/yourusernamehere/wordpress/" /tmp/wordpress/wp-tests-config.php
RUN sed -i "s/yourpasswordhere/wordpress/" /tmp/wordpress/wp-tests-config.php

RUN apt-get -y install default-mysql-client less

RUN curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN curl -sLO https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 \
    && chmod +x mhsendmail_linux_amd64 \
    && mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail
