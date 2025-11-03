#!/bin/bash
set -euo pipefail

SSL_DIR="/etc/nginx/ssl"
CRT="${SSL_DIR}/yhamdan.42.fr.crt"
KEY="${SSL_DIR}/yhamdan.42.fr.key"

mkdir -p "${SSL_DIR}"

# If cert/key missing, generate a self-signed cert
if [ ! -f "${CRT}" ] || [ ! -f "${KEY}" ]; then
    echo "[INFO] Generating self-signed SSL certificate for yhamdan.42.fr..."
    openssl req -x509 -nodes -days 365 \
        -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=yhamdan.42.fr" \
        -newkey rsa:2048 -keyout "${KEY}" -out "${CRT}" \
        >/dev/null 2>&1 || {
            echo "[WARN] openssl failed to generate cert — check openssl availability"; exit 1;
        }
    chmod 600 "${KEY}"
    chmod 644 "${CRT}"
fi

echo "[INFO] SSL certificate ready: ${CRT}"

# Start nginx in foreground
exec nginx -g "daemon off;"
