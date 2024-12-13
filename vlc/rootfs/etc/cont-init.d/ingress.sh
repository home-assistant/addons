#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Prepare VLC for ingress access
# ==============================================================================

# Generate NGINX config
bashio::var.json \
    supervisor_ip "$(getent hosts supervisor | awk '{ print $1 }' | head -1)" \
    | tempio \
        -template /usr/share/tempio/nginx.conf \
        -out /etc/nginx/nginx.conf
