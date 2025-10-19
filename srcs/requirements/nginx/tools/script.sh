#!/bin/sh
set -e

CERT_DIR=/etc/nginx/certs
mkdir -p "$CERT_DIR"
DN="${DOMAIN_NAME:-localhost}"

# Self-signed üret (yoksa)
if [ ! -f "$CERT_DIR/privkey.pem" ] || [ ! -f "$CERT_DIR/fullchain.pem" ]; then
  echo "[nginx] generating self-signed cert for ${DN}"
  openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout "$CERT_DIR/privkey.pem" \
    -out "$CERT_DIR/fullchain.pem" \
    -subj "/CN=${DN}"
fi

# Template -> gerçek config (http.d yolunda!)
if [ -f /etc/nginx/http.d/site.conf.template ]; then
  envsubst '${DOMAIN_NAME}' \
    < /etc/nginx/http.d/site.conf.template \
    > /etc/nginx/http.d/site.conf
fi

nginx -t
exec nginx -g 'daemon off;'
