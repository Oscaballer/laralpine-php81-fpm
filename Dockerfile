FROM alpine:3.17
LABEL Maintainer="Oscar Caballero <hola@ehupi.com>"
LABEL Description="Container with Nginx 1.22.1-r0 & PHP-fpm 8.1.16-r0 Alpine 3.17."

# Install system dependencies
RUN apk update && apk add --no-cache \
    bash \
    curl \
    nginx \
    supervisor \
    libpng-dev \
    libzip-dev \
    oniguruma-dev \
    wget \
    nano

# Install PHP and extensions
RUN apk add --no-cache \
  php81 \
  php81-ctype \
  php81-curl \
  php81-dom \
  php81-fpm \
  php81-gd \
  php81-intl \
  php81-mbstring \
  php81-mysqli \
  php81-opcache \
  php81-openssl \
  php81-phar \
  php81-session \
  php81-xml \
  php81-xmlreader \
  php81-zlib \
  php81-fileinfo \
  php81-xmlwriter \
  php81-tokenizer \
  php81-pdo_mysql \
  php81-exif \
  php81-iconv \
  php81-zip \
  php81-simplexml \
  php81-soap \
  php81-sodium

# Create symbolic links for PHP
# RUN ln -s /usr/bin/php81 /usr/bin/php && ln -s /etc/php81 /etc/php

COPY config/nginx.conf /etc/nginx/nginx.conf

COPY config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf
COPY config/php.ini /etc/php81/conf.d/custom.ini

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

RUN chown -R nobody.nobody /var/www/html /run /var/lib/nginx /var/log/nginx

USER nobody

COPY --chown=nobody src/ /var/www/html/

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
