#!/bin/bash
set -e

# Start MariaDB in the background once
echo " Starting MariaDB..."
mysqld_safe --datadir=/var/lib/mysql &

# Wait until it’s ready
echo " Waiting for MariaDB to start..."
until mysqladmin ping --silent; do
    echo "MariaDB starting..."
    sleep 2
done
echo " MariaDB is ready!"

# Connect as root (with or without password)
if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
    MYSQL_CMD="mysql -u root -p${MYSQL_ROOT_PASSWORD}"
else
    MYSQL_CMD="mysql -u root"
fi

# Create database and user
$MYSQL_CMD <<-EOSQL
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

# Stop background process if still running
echo " Stopping background MariaDB setup..."
mysqladmin shutdown -u root ${MYSQL_ROOT_PASSWORD:+-p${MYSQL_ROOT_PASSWORD}} || true

# Now start MariaDB in foreground (PID 1)
echo " MariaDB setup complete — running foreground."
exec mysqld_safe --datadir=/var/lib/mysql
