#!/usr/bin/env bashio
set -e

DHPARAMS_PATH=/data/dhparams.pem

SNAKEOIL_CERT=/data/ssl-cert-snakeoil.pem
SNAKEOIL_KEY=/data/ssl-cert-snakeoil.key

CLOUDFLARE_CONF=/data/cloudflare.conf

ALLOWLIST_CONF=/data/remotes_allowlist.conf

DOMAIN=$(bashio::config 'domain')
KEYFILE=$(bashio::config 'keyfile')
CERTFILE=$(bashio::config 'certfile')
HSTS=$(bashio::config 'hsts')

HA_PORT=$(bashio::core.port)

# Generate dhparams
if ! bashio::fs.file_exists "${DHPARAMS_PATH}"; then
    bashio::log.info  "Generating dhparams (this will take some time)..."
    openssl dhparam -dsaparam -out "$DHPARAMS_PATH" 4096 > /dev/null
fi

if ! bashio::fs.file_exists "${SNAKEOIL_CERT}"; then
    bashio::log.info "Creating 'snakeoil' self-signed certificate..."
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout $SNAKEOIL_KEY -out $SNAKEOIL_CERT -subj '/CN=localhost'
fi

# Fetch Cloudflare IPs if neeeded for proxy trusting or allowlist filtering
CF_IPV4_LIST=""
CF_IPV6_LIST=""

if bashio::config.true 'cloudflare' || bashio::config.true 'allowlist.cloudflare'; then
    CF_IPV4_LIST=$(curl https://www.cloudflare.com/ips-v4)
    CF_IPV6_LIST=$(curl https://www.cloudflare.com/ips-v6)
fi

# Configure nginx for trusting client IPs from Cloudflare headers
if bashio::config.true 'cloudflare'; then
    sed -i "s|#include /data/cloudflare.conf;|include /data/cloudflare.conf;|" /etc/nginx.conf
    # Generate cloudflare.conf
    if ! bashio::fs.file_exists "${CLOUDFLARE_CONF}"; then
        bashio::log.info "Creating 'cloudflare.conf' for real visitor IP address..."
        echo "# Cloudflare IP addresses" > $CLOUDFLARE_CONF;
        echo "" >> $CLOUDFLARE_CONF;

        echo "# - IPv4" >> $CLOUDFLARE_CONF;
        for i in $CF_IPV4_LIST; do
            echo "set_real_ip_from ${i};" >> $CLOUDFLARE_CONF;
        done

        echo "" >> $CLOUDFLARE_CONF;
        echo "# - IPv6" >> $CLOUDFLARE_CONF;
        for i in $CF_IPV6_LIST; do
            echo "set_real_ip_from ${i};" >> $CLOUDFLARE_CONF;
        done

        echo "" >> $CLOUDFLARE_CONF;
        echo "real_ip_header CF-Connecting-IP;" >> $CLOUDFLARE_CONF;
    fi
fi

ALLOWLIST_IF=""
if bashio::config.true 'allowlist.active'; then
    sed -i "s|#include /data/remotes_allowlist.conf;|include /data/remotes_allowlist.conf;|" /etc/nginx.conf
    ALLOWLIST_IF="if (\$allowed_ip != 1) { return 403; }"

    bashio::log.info "Creating 'remotes_allowlist.conf' for filtering allowed remote IPs..."
    {
        echo "geo \$realip_remote_addr \$allowed_ip {"
        echo "    default 0;"

        # Add static entries from config
        if bashio::config.has_value 'allowlist.entries'; then
            echo ""
            echo "    # Static entries"
            echo ""

            for i in $(bashio::config 'allowlist.entries'); do
                echo "    ${i} 1;"
            done
        fi

        # Add Cloudflare IPs if enabled
        if bashio::config.true 'allowlist.cloudflare'; then
            echo ""
            echo "    # Cloudflare IP addresses"
            echo ""

            echo "    # - IPv4"
            for i in $CF_IPV4_LIST; do
                echo "    ${i} 1;"
            done

            echo ""
            echo "    # - IPv6"
            for i in $CF_IPV6_LIST; do
                echo "    ${i} 1;"
            done
        fi

        echo "}"
    } > $ALLOWLIST_CONF
fi
sed -i "s|%%ALLOWLIST_IF%%|$ALLOWLIST_IF|g" /etc/nginx.conf

# Prepare config file
sed -i "s#%%FULLCHAIN%%#$CERTFILE#g" /etc/nginx.conf
sed -i "s#%%PRIVKEY%%#$KEYFILE#g" /etc/nginx.conf
sed -i "s/%%DOMAIN%%/$DOMAIN/g" /etc/nginx.conf
sed -i "s/%%HA_PORT%%/$HA_PORT/g" /etc/nginx.conf

[ -n "$HSTS" ] && HSTS="add_header Strict-Transport-Security \"$HSTS\" always;"
sed -i "s/%%HSTS%%/$HSTS/g" /etc/nginx.conf

# Allow customize configs from share
if bashio::config.true 'customize.active'; then
    CUSTOMIZE_DEFAULT=$(bashio::config 'customize.default')
    sed -i "s|#include /share/nginx_proxy_default.*|include /share/$CUSTOMIZE_DEFAULT;|" /etc/nginx.conf
    CUSTOMIZE_SERVERS=$(bashio::config 'customize.servers')
    sed -i "s|#include /share/nginx_proxy/.*|include /share/$CUSTOMIZE_SERVERS;|" /etc/nginx.conf
fi

# start server
bashio::log.info "Running nginx..."
exec nginx -c /etc/nginx.conf < /dev/null
