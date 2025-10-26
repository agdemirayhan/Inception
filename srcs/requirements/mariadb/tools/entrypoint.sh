#!/bin/bash
# ----------------------------------------------------------
# MariaDB Initialization and Configuration Script
# ----------------------------------------------------------
# This script initializes the MariaDB data directory (if empty),
# starts the database server, waits until it's ready,
# and then creates the database and user with proper permissions.
# ----------------------------------------------------------

DB_DIR="/var/lib/mysql"

# Read passwords from Docker secrets
DB_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
DB_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")

# Initialize the database if the system tables don't exist
if [ ! -d "$DB_DIR/mysql" ]; then
	echo "[INFO] Initializing MariaDB data directory..."
	mariadb-install-db --user=mysql --basedir=/usr --datadir="$DB_DIR"
fi

# Allow connections from any address (required for Docker networking)
sed -i "s|bind-address\s*=\s*127.0.0.1|bind-address = 0.0.0.0|g" /etc/mysql/mariadb.conf.d/50-server.cnf

# Start MariaDB in the background
echo "[INFO] Starting MariaDB..."
mysqld_safe --datadir="$DB_DIR" &

# Wait for the server to accept connections (max 30s)
for i in {1..30}; do
	if mysqladmin ping --silent; then
		break
	fi
	echo "[INFO] Waiting for MariaDB to be ready..."
	sleep 1
done

echo "[INFO] Applying database configuration..."

# Secure and configure MariaDB
mysql -u root -p"${DB_ROOT_PASSWORD}" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"

# Create database if it doesn't exist
mysql -u root -p"${DB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"

# Create user for WordPress (accessible from different hosts)
mysql -u root -p"${DB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -u root -p"${DB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -u root -p"${DB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'wp-php.srcs_inception' IDENTIFIED BY '${DB_PASSWORD}';"

# Grant privileges on the WordPress database to the created user
mysql -u root -p"${DB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';"
mysql -u root -p"${DB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';"
mysql -u root -p"${DB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'wp-php.srcs_inception';"

# Apply privilege changes
mysql -u root -p"${DB_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

echo "[INFO] MariaDB setup complete!"
wait
