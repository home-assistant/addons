#!/usr/bin/with-contenv bashio
# ==============================================================================
# Create VLC secret
# ==============================================================================

# Generate password
if bashio::fs.file_exists /data/ingress-secret; then
    bashio::exit.ok
else
    pwgen 64 1 > /data/ingress-secret
fi

# ==============================================================================
# Prepair VLC for ingress access
# ==============================================================================

# Generate NGINX config
bashio::var.json \
    supervisor_ip "$(getent hosts supervisor | awk '{ print $1 }' | head -1)" \
    ingress_secret "$(awk '{v=":"; print v$1}' /data/ingress-secret | base64)" \
    | tempio \
        -template /usr/share/tempio/nginx.conf \
        -out /etc/nginx/nginx.conf
