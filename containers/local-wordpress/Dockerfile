FROM wordpress:latest

RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN docker-php-ext-install pdo_mysql

RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data
