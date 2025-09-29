FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends php8.2-fpm \
 && rm -rf /var/lib/apt/lists/*
EXPOSE 9000
COPY www.conf /etc/php/8.2/fpm/pool.d/.
CMD ["php-fpm8.2", "-F"]
