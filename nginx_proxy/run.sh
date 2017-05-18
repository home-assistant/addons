#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
DHPARAMS_PATH=/data/dhparams.pem

KEYFILE=$(jq --raw-output ".keyfile" $CONFIG_PATH)
CERTFILE=$(jq --raw-output ".certfile" $CONFIG_PATH)


# Generate dhparams
if [ ! -f "$DHPARAMS_PATH" ]; then
    echo "[INFO] Generate dhparams..."
    openssl dhparam -dsaparam -out "$DHPARAMS_PATH" 4096 > /dev/null
fi

# Prepare config file
sed -i "s/%%FULLCHAIN%%/$CERTFILE/g" /etc/nginx.conf
sed -i "s/%%PRIVKEY%%/$KEYFILE/g" /etc/nginx.conf

# start server
echo "[INFO] Run nginx"
exec nginx -c /etc/nginx.conf < /dev/null
