#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
DHPARAMS_PATH=/data/dhparams.pem

SNAKEOIL_CERT=/etc/ssl/certs/ssl-cert-snakeoil.pem
SNAKEOIL_KEY=/etc/ssl/private/ssl-cert-snakeoil.key

DOMAIN=$(jq --raw-output ".domain" $CONFIG_PATH)
KEYFILE=$(jq --raw-output ".keyfile" $CONFIG_PATH)
CERTFILE=$(jq --raw-output ".certfile" $CONFIG_PATH)

# Generate dhparams
if [ ! -f "$DHPARAMS_PATH" ]; then
    echo "[INFO] Generate dhparams..."
    openssl dhparam -dsaparam -out "$DHPARAMS_PATH" 4096 > /dev/null
fi

if [ ! -f "$SNAKEOIL_CERT" ]; then
    echo "[INFO] Create snakeoil (self-signed certificate)"
    mkdir -p "$(dirname $SNAKEOIL_CERT)"
    mkdir -p "$(dirname $SNAKEOIL_KEY)"
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout $SNAKEOIL_KEY -out $SNAKEOIL_CERT -subj '/CN=localhost'
fi

# Prepare config file
sed -i "s/%%FULLCHAIN%%/$CERTFILE/g" /etc/nginx.conf
sed -i "s/%%PRIVKEY%%/$KEYFILE/g" /etc/nginx.conf
sed -i "s/%%DOMAIN%%/$DOMAIN/g" /etc/nginx.conf

# start server
echo "[INFO] Run nginx"
exec nginx -c /etc/nginx.conf < /dev/null
