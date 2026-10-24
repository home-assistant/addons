#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Configures NGINX
# ==============================================================================
bashio::var.json \
  acl_enforced "^$(bashio::config.has_value 'acl_file' && echo true || echo false)" \
  | tempio \
    -template /usr/share/tempio/nginx.gtpl \
    -out /etc/nginx/nginx.conf
