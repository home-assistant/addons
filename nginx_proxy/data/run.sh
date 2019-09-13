#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
DHPARAMS_PATH=/data/dhparams.pem

SNAKEOIL_CERT=/data/ssl-cert-snakeoil.pem
SNAKEOIL_KEY=/data/ssl-cert-snakeoil.key

CLOUDFLARE_CONF=/data/cloudflare.conf

DOMAIN=$(jq --raw-output ".domain" $CONFIG_PATH)
KEYFILE=$(jq --raw-output ".keyfile" $CONFIG_PATH)
CERTFILE=$(jq --raw-output ".certfile" $CONFIG_PATH)
HSTS=$(jq --raw-output ".hsts // empty" $CONFIG_PATH)
CUSTOMIZE_ACTIVE=$(jq --raw-output ".customize.active" $CONFIG_PATH)
CLOUDFLARE_ENABLED=$(jq --raw-output ".cloudflare.enabled" $CONFIG_PATH)
CLOUDFLARE_REAL_IP_HEADER=$(jq --raw-output ".cloudflare.real_ip_header" $CONFIG_PATH)

# Generate dhparams
if [ ! -f "$DHPARAMS_PATH" ]; then
    echo "[INFO] Generating dhparams (this will take some time)..."
    openssl dhparam -dsaparam -out "$DHPARAMS_PATH" 4096 > /dev/null
fi

if [ ! -f "$SNAKEOIL_CERT" ]; then
    echo "[INFO] Creating 'snakeoil' self-signed certificate..."
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout $SNAKEOIL_KEY -out $SNAKEOIL_CERT -subj '/CN=localhost'
fi

if [ "$CLOUDFLARE_ENABLED" == "true" ]; then
    # Generate cloudflare.conf
    if [ ! -f "$CLOUDFLARE_CONF" ]; then
        echo "[INFO] Creating 'cloudflare.conf' for real visitor IP address..."
        echo "# Cloudflare IP addresses" > $CLOUDFLARE_CONF;
        echo "" >> $CLOUDFLARE_CONF;

        echo "# - IPv4" >> $CLOUDFLARE_CONF;
        for i in `curl https://www.cloudflare.com/ips-v4`; do
            echo "set_real_ip_from $i;" >> $CLOUDFLARE_CONF;
        done
        
        echo "" >> $CLOUDFLARE_CONF;
        echo "# - IPv6" >> $CLOUDFLARE_CONF;
        for i in `curl https://www.cloudflare.com/ips-v6`; do
            echo "set_real_ip_from $i;" >> $CLOUDFLARE_CONF;
        done
        
        echo "" >> $CLOUDFLARE_CONF;
        echo "real_ip_header ${CLOUDFLARE_REAL_IP_HEADER};" >> $CLOUDFLARE_CONF;
    fi
fi

# Prepare config file
sed -i "s/%%FULLCHAIN%%/$CERTFILE/g" /etc/nginx.conf
sed -i "s/%%PRIVKEY%%/$KEYFILE/g" /etc/nginx.conf
sed -i "s/%%DOMAIN%%/$DOMAIN/g" /etc/nginx.conf

[ -n "$HSTS" ] && HSTS="add_header Strict-Transport-Security \"$HSTS\";"
sed -i "s/%%HSTS%%/$HSTS/g" /etc/nginx.conf

# Allow customize configs from share
if [ "$CUSTOMIZE_ACTIVE" == "true" ]; then
    CUSTOMIZE_DEFAULT=$(jq --raw-output ".customize.default" $CONFIG_PATH)
    sed -i "s|#include /share/nginx_proxy_default.*|include /share/$CUSTOMIZE_DEFAULT;|" /etc/nginx.conf
    CUSTOMIZE_SERVERS=$(jq --raw-output ".customize.servers" $CONFIG_PATH)
    sed -i "s|#include /share/nginx_proxy/.*|include /share/$CUSTOMIZE_SERVERS;|" /etc/nginx.conf
fi

# start server
echo "[INFO] Running nginx..."
exec nginx -c /etc/nginx.conf < /dev/null
