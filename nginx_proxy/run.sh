#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir
WELL_KNOWN=/data/well-known
DHPARAMS_PATH=/data/dhparams.pem

SNAKEOIL_CERT=/data/ssl-cert-snakeoil.pem
SNAKEOIL_KEY=/data/ssl-cert-snakeoil.key

DOMAIN=$(jq --raw-output '.domain' $CONFIG_PATH)
KEYFILE=$(jq --raw-output '.keyfile' $CONFIG_PATH)
CERTFILE=$(jq --raw-output '.certfile' $CONFIG_PATH)

LE_TERMS=$(jq --raw-output '.lets_encrypt.accept_terms' $CONFIG_PATH)
LE_UPDATE="0"

# Generate dhparams
if [ ! -f "$DHPARAMS_PATH" ]; then
    echo "[INFO] Generate dhparams..."
    openssl dhparam -dsaparam -out "$DHPARAMS_PATH" 4096 > /dev/null
fi

if [ ! -f "$SNAKEOIL_CERT" ]; then
    echo "[INFO] Create snakeoil (self-signed certificate)"
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout $SNAKEOIL_KEY -out $SNAKEOIL_CERT -subj '/CN=localhost'
fi

# Function that performe a renew for Let's Encrypt
function le_renew() {
    dehydrated --cron --hook ./hooks.sh --challenge http-01 --domain "$DOMAIN" --out "$CERT_DIR" --config "$WORK_DIR/config" || true
    LE_UPDATE="$(date +%s)"
}

# Register/generate certificate if terms accepted
if [ "$LE_TERMS" == "true" ]; then
    # Init folder structs
    mkdir -p "$CERT_DIR"
    mkdir -p "$WORK_DIR"
    mkdir -p "$WELL_KNOWN"

    # Generate new certs
    if [ ! -d "$CERT_DIR/live" ]; then
        # Create empty dehydrated config file so that this dir will be used for storage
        echo "WELLKNOWN=$WELL_KNOWN" > "$WORK_DIR/config"

        dehydrated --register --accept-terms --config "$WORK_DIR/config"
    fi
fi

# Prepare config file
sed -i "s/%%FULLCHAIN%%/$CERTFILE/g" /etc/nginx.conf
sed -i "s/%%PRIVKEY%%/$KEYFILE/g" /etc/nginx.conf
sed -i "s/%%DOMAIN%%/$DOMAIN/g" /etc/nginx.conf

# start server
echo "[INFO] Run nginx"
exec nginx -c /etc/nginx.conf < /dev/null
