#!/usr/bin/env bash
set -euo pipefail

# --- Load secrets ---
DB_PASS=$(cat /run/secrets/db_password)
ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
USER_PASS=$(cat /run/secrets/wp_user_password)

# --- Load environment variables ---
DB_NAME=${WORDPRESS_DB_NAME}
DB_USER=${WORDPRESS_DB_USER}
DB_HOST=${WORDPRESS_DB_HOST}

WP_TITLE=${WP_TITLE:-INCEPTION}
WP_URL=${WP_URL:-https://aagdemir.42.fr}
WP_ADMIN_USER=${WP_ADMIN_USER:-aagdemir}
WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL:-admin@example.com}
WP_USER=${WP_USER:-editor_user}
WP_USER_EMAIL=${WP_USER_EMAIL:-user@example.com}

# --- Wait for MariaDB to be ready ---
echo "Waiting for MariaDB at ${DB_HOST}..."
until mysqladmin ping -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" --silent; do
	sleep 2
done
echo "MariaDB is ready."

# --- WordPress installation ---
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress not configured yet. Setting up..."
    if [ ! -d /var/www/html/wp-admin ]; then
        echo "Downloading WordPress..."
        wp core download --allow-root --path=/var/www/html
    fi

	echo "Creating wp-config.php..."
	wp config create --allow-root \
		--dbname="${DB_NAME}" \
		--dbuser="${DB_USER}" \
		--dbpass="${DB_PASS}" \
		--dbhost="${DB_HOST}" \
		--path=/var/www/html --force

	echo "Installing WordPress..."
	wp core install --allow-root \
		--url="${WP_URL}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${ADMIN_PASS}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--path=/var/www/html

	echo "Creating secondary user..."
	wp user create --allow-root "${WP_USER}" "${WP_USER_EMAIL}" \
		--user_pass="${USER_PASS}" \
		--role=editor \
		--path=/var/www/html

fi

# --- Permissions ---
echo "Setting correct file permissions..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# --- Start PHP-FPM ---
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm8.2 -F
