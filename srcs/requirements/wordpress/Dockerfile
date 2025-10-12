FROM wordpress:php8.2-fpm
# Gerekli ekstra ext/araçları burada apt-get ile ekleyebilirsin (bookworm tabanlıdır).
# Örn:
RUN apt-get update && apt-get install -y --no-install-recommends libzip-dev \
    && docker-php-ext-install zip && rm -rf /var/lib/apt/lists/*