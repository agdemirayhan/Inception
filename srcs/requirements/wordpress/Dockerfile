FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	php8.2-fpm php8.2-cli php8.2-mysql curl \
	default-mysql-client \
&& rm -rf /var/lib/apt/lists/*

RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf \
&& sed -i 's|^;listen.owner = www-data|listen.owner = www-data|' /etc/php/8.2/fpm/pool.d/www.conf \
&& sed -i 's|^;listen.group = www-data|listen.group = www-data|' /etc/php/8.2/fpm/pool.d/www.conf \
&& sed -i 's|^;listen.mode = 0660|listen.mode = 0660|' /etc/php/8.2/fpm/pool.d/www.conf

RUN mkdir -p /run/php /var/www/html

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	-o /usr/local/bin/wp && chmod +x /usr/local/bin/wp

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /var/www/html
EXPOSE 9000
ENTRYPOINT ["/entrypoint.sh"]