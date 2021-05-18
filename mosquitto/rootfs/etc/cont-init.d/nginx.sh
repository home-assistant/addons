#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configures NGINX
# ==============================================================================
# This template only uses environment vars, no input
echo "{}" \
  | tempio \
    -template /etc/nginx/nginx.gtpl \
    -out /etc/nginx/nginx.conf
