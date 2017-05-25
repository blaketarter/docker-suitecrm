FROM php:5.6-apache
MAINTAINER Kerry Knopp <kerry@codekoalas.com>

COPY config/php.ini /usr/local/etc/php/

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libpng12-dev \
        libpq-dev \
        libxml2-dev \
        zlib1g-dev \
        libc-client-dev \
        libkrb5-dev \
        libldap2-dev \
        cron \
        && apt-get clean

RUN docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
        curl \
        mbstring \
        zip \
        ftp \
        gd \
        fileinfo \
        soap \
        zip \
        imap

# Add SuiteCRM code
# COPY /src /var/www/html

RUN (crontab -l 2>/dev/null; echo "*    *    *    *    *     cd /var/www/html; php -f cron.php > /dev/null 2>&1 ") | crontab -
RUN chown www-data:www-data /var/www/html/ -R

# Create volumes. Will change when build process is in place
VOLUME /var/www/html/

WORKDIR /var/www/html
EXPOSE 80