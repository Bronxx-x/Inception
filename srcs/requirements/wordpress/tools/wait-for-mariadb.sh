#!/bin/bash
set -e

DB_HOST="$1"

echo " Waiting for MariaDB at $DB_HOST..."
until mysqladmin ping -h "$DB_HOST" --silent; do
    echo "MariaDB not ready yet..."
    sleep 2
done
echo " MariaDB is ready!"

# Optional: run setup.sh
if [ -f /usr/local/bin/setup.sh ]; then
    /usr/local/bin/setup.sh || true
fi

# Remove old PID file in case PHP-FPM thinks it's still running
rm -f /run/php/php7.4-fpm.pid

# Ensure no old FPM process is running
pkill -f php-fpm7.4 || true

# Start PHP-FPM in foreground with remote connections allowed
echo " Starting PHP-FPM..."
exec php-fpm7.4 -F -R
