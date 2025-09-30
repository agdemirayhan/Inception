FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install PHP-FPM + MySQL extension + curl
# php-mysql provides mysqli and pdo_mysql
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    php-fpm \
    php-mysql \
    curl \
 && rm -rf /var/lib/apt/lists/*

# Put your pool config in place for the installed PHP version
# (Bookworm ships PHP 8.2, but this works even if it changes later)
COPY www.conf /tmp/www.conf
RUN set -eux; \
    php_ver="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')" ; \
    install -m 0644 /tmp/www.conf "/etc/php/${php_ver}/fpm/pool.d/www.conf" ; \
    rm /tmp/www.conf

EXPOSE 9000

CMD ["php-fpm8.2", "-F"]
