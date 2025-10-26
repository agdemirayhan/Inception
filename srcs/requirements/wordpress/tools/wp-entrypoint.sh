#!/usr/bin/env sh
set -euo pipefail

# Varsayılanlar
: "${WP_PATH:=/var/www/html}"
: "${WORDPRESS_TABLE_PREFIX:=wp_}"

# DB bekle
DB_HOST="${WORDPRESS_DB_HOST%:*}"
DB_PORT="${WORDPRESS_DB_HOST##*:}"
[ "$DB_HOST" = "$DB_PORT" ] && DB_PORT=3306

echo "[wp] Waiting for DB at ${DB_HOST}:${DB_PORT}..."
for i in $(seq 1 60); do
  if nc -z "${DB_HOST}" "${DB_PORT}"; then
    echo "[wp] DB is up."; break
  fi
  sleep 1
done

# İlk kurulum (idempotent)
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
  echo "[wp] Downloading WordPress core..."
  mkdir -p "${WP_PATH}"
  cd "${WP_PATH}"

  wp core download --allow-root

  echo "[wp] Creating wp-config.php..."
  wp config create \
    --dbname="${WORDPRESS_DB_NAME}" \
    --dbuser="${WORDPRESS_DB_USER}" \
    --dbpass="${WORDPRESS_DB_PASSWORD}" \
    --dbhost="${WORDPRESS_DB_HOST}" \
    --dbprefix="${WORDPRESS_TABLE_PREFIX}" \
    --skip-check \
    --allow-root

  echo "[wp] Installing site..."
  wp core install \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root

  echo "Updating WordPress URL settings..."
	wp option update --allow-root home "${WP_URL}" --path=/var/www/html
	wp option update --allow-root siteurl "${WP_URL}" --path=/var/www/html

	# --- Ensure title matches env file ---
	wp option update --allow-root blogname "${WP_TITLE}" --path=/var/www/html

  # İkinci kullanıcı (opsiyonel)
  if [ -n "${WP_USER:-}" ] && [ -n "${WP_USER_PASSWORD:-}" ] && [ -n "${WP_USER_EMAIL:-}" ]; then
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
      --user_pass="${WP_USER_PASSWORD}" \
      --role=author \
      --allow-root || true
  fi

  chown -R www-data:www-data "${WP_PATH}"
fi

echo "[wp] Starting php-fpm..."
exec /usr/sbin/php-fpm82 -F -R
