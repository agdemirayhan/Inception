FROM wordpress:php8.2-fpm

RUN apt-get update && apt-get install -y --no-install-recommends libzip-dev \
    && docker-php-ext-install zip && rm -rf /var/lib/apt/lists/*