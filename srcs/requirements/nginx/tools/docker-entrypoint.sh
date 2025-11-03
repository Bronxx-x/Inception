#!/bin/bash
set -e

SSL_DIR="/etc/nginx/ssl"
CRT="$SSL_DIR/server.crt"
KEY="$SSL_DIR/server.key"

# Create SSL dir if it doesn't exist
mkdir -p "$SSL_DIR"

# Generate self-signed certificate if not present
if [ ! -f "$CRT" ] || [ ! -f "$KEY" ]; then
    echo "[INFO] Generating self-signed SSL certificate..."
    openssl req -x509 -nodes -days 365 \
        -subj "/CN=yhamdan.42.fr" \
        -newkey rsa:2048 \
        -keyout "$KEY" \
        -out "$CRT"
fi

echo "[INFO] SSL certificate ready: $CRT"
exec "$@"
