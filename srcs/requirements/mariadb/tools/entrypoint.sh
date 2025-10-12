#!/usr/bin/env bash
set -euo pipefail

DATADIR="/var/lib/mysql"
RUNDIR="/run/mysqld"
ROOT_PW_FILE="/run/secrets/db_root_password"
USER_PW_FILE="/run/secrets/db_password"

: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"

# runtime ve data dizinleri
mkdir -p "${RUNDIR}"
chown -R mysql:mysql "${RUNDIR}"
mkdir -p "${DATADIR}"
chown -R mysql:mysql "${DATADIR}"

if [ ! -d "${DATADIR}/mysql" ] || [ -z "$(ls -A "${DATADIR}/mysql" 2>/dev/null || true)" ]; then
  echo "[entrypoint] Initializing MariaDB datadir..."
  mariadb-install-db --user=mysql --datadir="${DATADIR}" --skip-test-db > /dev/null

  ROOT_PW="$(cat "${ROOT_PW_FILE}")"
  USER_PW="$(cat "${USER_PW_FILE}")"

  cat > /tmp/bootstrap.sql <<SQL
-- secure root and provision app db/user
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PW}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${ROOT_PW}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${USER_PW}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL

  echo "[entrypoint] Bootstrapping system tables & initial SQL..."
  mariadbd --user=mysql --datadir="${DATADIR}" --bootstrap --skip-networking < /tmp/bootstrap.sql
  rm -f /tmp/bootstrap.sql
fi

echo "[entrypoint] Starting MariaDB..."
exec mariadbd --user=mysql --bind-address=0.0.0.0 --datadir="${DATADIR}" --socket="${RUNDIR}/mysqld.sock" --pid-file="${RUNDIR}/mysqld.pid"
