ARG DEBIAN_VERSION=bookworm
FROM debian:${DEBIAN_VERSION}


ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    php${PHP_VERSION}-fpm php${PHP_VERSION}-mysqli php${PHP_VERSION}-curl php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-zip php${PHP_VERSION}-gd curl less mariadb-client \
 && rm -rf /var/lib/apt/lists/*

# wp-cli
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
 && chmod +x /usr/local/bin/wp

# php-fpm pool
COPY conf/www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

# docroot & giriş scripti
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www
COPY tools/wp-entrypoint.sh /usr/local/bin/wp-entrypoint.sh
RUN chmod +x /usr/local/bin/wp-entrypoint.sh

WORKDIR /var/www/html
EXPOSE 9000
VOLUME ["/var/www/html"]

# Secrets mount noktaları (compose verir)
ENTRYPOINT ["/usr/local/bin/wp-entrypoint.sh"]
