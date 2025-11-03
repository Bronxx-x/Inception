#!/bin/bash
set -euo pipefail

# This script:
# - waits for MariaDB
# - downloads / installs WP if missing
# - fixes ownership/permissions (important when using volumes)
# - finally execs php-fpm (via CMD from Dockerfile)

MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-changeme}"
MYSQL_DATABASE="${MYSQL_DATABASE:-wordpress}"
MYSQL_USER="${MYSQL_USER:-wpuser}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-changeme}"
DB_HOST="${WP_DB_HOST:-mariadb}"

WP_DIR="/var/www/wordpress"

echo "🔧 WordPress entrypoint: ensure directories & permissions..."
# Ensure runtime dirs exist and owned by www-data
mkdir -p "$WP_DIR"
mkdir -p /run/php
chown -R www-data:www-data "$WP_DIR" /run/php
chmod -R 755 "$WP_DIR"
# wp-config may contain secrets -> make owner readable by www-data only
# We'll adjust after download/install below.

echo "⏳ Waiting for MariaDB at ${DB_HOST}..."
until mysqladmin ping -h "${DB_HOST}" -u root -p"${MYSQL_ROOT_PASSWORD}" --silent 2>/dev/null; do
    echo "MariaDB not ready yet..."
    sleep 2
done
echo "✅ MariaDB is ready!"

# Download WordPress core if not present (run as root, but files will be chowned after)
if [ ! -f "${WP_DIR}/wp-load.php" ]; then
    echo "📦 Downloading WordPress core..."
    cd "$WP_DIR"
    wp core download --allow-root --quiet
fi

# Install WordPress only if not installed
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "⚡ Installing WordPress (WP-CLI)..."
    # Use provided env vars. Use site url from env DOMAIN_NAME or default.
    SITE_URL="${DOMAIN_NAME:-yhamdan.42.fr}"
    wp core install --allow-root \
        --url="https://${SITE_URL}" \
        --title="Inception WP" \
        --admin_user="${WP_ADMIN_USR:-admin}" \
        --admin_password="${WP_ADMIN_PWD:-changeme}" \
        --admin_email="${WP_ADMIN_EMAIL:-admin@${SITE_URL}}" \
        --skip-email
else
    echo "✅ WordPress already installed."
fi

# Ensure correct ownership and safe permissions after WP files exist
echo "🔐 Fixing file ownership & permissions for WordPress..."
chown -R www-data:www-data "$WP_DIR"
# directories 755, files 644 (except wp-config.php)
find "$WP_DIR" -type d -exec chmod 755 {} \;
find "$WP_DIR" -type f -exec chmod 644 {} \;

# wp-config.php: readable by owner (www-data) and root; ensure owner is www-data
if [ -f "${WP_DIR}/wp-config.php" ]; then
    chown www-data:www-data "${WP_DIR}/wp-config.php"
    chmod 640 "${WP_DIR}/wp-config.php"
fi

# Ensure /run/php exists and is writable by www-data (php-fpm needs pid file)
mkdir -p /run/php
chown -R www-data:www-data /run/php
chmod 755 /run/php

echo "✅ WordPress setup complete. Handing off to php-fpm (CMD)."
# exec returns control to CMD (php-fpm) from Dockerfile
exec "$@"
