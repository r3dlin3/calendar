FROM php:8-apache-buster
ARG BAIKAL_VERSION=0.8.0

LABEL author="r3dLiN3"
# LABEL copyright="(c) Copyright 2015, 2016 by CIME Software Ltd."
LABEL description="Baikal / SabreDAV robust calendar and address book server with scheduling and email notifications"
# LABEL license="See: LICENSE.txt for complete licensing information."
# LABEL support="caldav AT cime.net"
LABEL version="1.0"
    
### Install the main set of system requirements
# curl already present
RUN apt-get update && apt-get install -y \
    unzip \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

### "Baikal-installation"

RUN cd /tmp/ && curl --silent -LO https://github.com/sabre-io/Baikal/releases/download/${BAIKAL_VERSION}/baikal-${BAIKAL_VERSION}.zip \
 && unzip /tmp/baikal-${BAIKAL_VERSION}.zip -d /var/www/ \
 && rm -f /var/www/baikal/html/Specific/db/.empty /tmp/baikal-${BAIKAL_VERSION}.zip

# Changing DocumentRoot
ENV APACHE_DOCUMENT_ROOT /var/www/baikal/html/

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

#OPCache
RUN docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install opcache
COPY resources/opcache.ini $PHP_INI_DIR/conf.d/

RUN chown -Rf www-data:www-data /var/www/baikal/Specific \
 && chown -Rf www-data:www-data /var/www/baikal/config \
 && a2enmod rewrite 



