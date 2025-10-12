#!/usr/bin/env bash
set -e

DOCROOT="/var/www/html"

# WP yoksa indir
if [ ! -f "${DOCROOT}/wp-config.php" ]; then
  cd ${DOCROOT}
  # wp-cli kurulu varsayıyoruz (Dockerfile'da)
  wp core download --allow-root
  wp config create --allow-root \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="$(cat /run/secrets/db_password)" \
    --dbhost="mariadb:3306" \
    --skip-check

  wp core install --allow-root \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="$(cat /run/secrets/credentials)" \
    --admin_email="${WP_ADMIN_EMAIL}"
fi

# php-fpm PID1 olacak
exec php-fpm${PHP_VERSION%.*} -F
