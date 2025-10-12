#!/usr/bin/env bash
set -e

DOCROOT="/var/www/html"
DB_HOST="mariadb"
DB_PORT="3306"

# DB hazır mı? (60 sn'ye kadar, kullanıcı/şifreyle ping)
for i in $(seq 1 60); do
  if mysqladmin ping \
      -h "${DB_HOST}" -P "${DB_PORT}" --protocol=TCP \
      -u "${MYSQL_USER}" -p"$(cat /run/secrets/db_password)" >/dev/null 2>&1; then
    break
  fi
  echo "[wp-entrypoint] Waiting for DB... (${i}/60)"
  sleep 1
done

cd "${DOCROOT}"

# wp-config yanlışsa/sorunluysa sıfırdan üret
if [ -f "wp-config.php" ]; then
  if ! mysql -h "${DB_HOST}" -P "${DB_PORT}" --protocol=TCP \
       -u "${MYSQL_USER}" -p"$(cat /run/secrets/db_password)" -e "SELECT 1" >/dev/null 2>&1; then
    echo "[wp-entrypoint] DB creds failed; recreating wp-config.php"
    rm -f wp-config.php
  fi
fi

# WordPress indir & config oluştur
if [ ! -f "wp-config.php" ]; then
  echo "[wp-entrypoint] Downloading WordPress (idempotent)..."
  wp core download --allow-root || true

  echo "[wp-entrypoint] Creating wp-config.php..."
  wp config create --allow-root \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="$(cat /run/secrets/db_password)" \
    --dbhost="${DB_HOST}:${DB_PORT}" \
    --skip-check || true
fi

# Kurulu mu? Kur değilse kur
if ! wp core is-installed --allow-root; then
  echo "[wp-entrypoint] Installing WordPress..."
  wp core install --allow-root \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="$(cat /run/secrets/credentials)" \
    --admin_email="${WP_ADMIN_EMAIL}" || true
else
  echo "[wp-entrypoint] WordPress already installed."
fi

# izinler (Windows mount'ta sorun çıkarsa hata bastır)
chown -R www-data:www-data "${DOCROOT}" || true

# Doğru php-fpm binary'sini bul
PHP_FPM_BIN="$(command -v php-fpm${PHP_VERSION} || true)"
if [ -z "$PHP_FPM_BIN" ]; then
  PHP_FPM_BIN="$(command -v php-fpm${PHP_VERSION%.*} || true)"
fi
if [ -z "$PHP_FPM_BIN" ]; then
  PHP_FPM_BIN="$(command -v php-fpm || true)"
fi
if [ -z "$PHP_FPM_BIN" ]; then
  echo "[wp-entrypoint] ERROR: php-fpm binary not found"; sleep 2; exit 1
fi

exec "$PHP_FPM_BIN" -F
