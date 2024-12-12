#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Configures NGINX
# ==============================================================================
# This template only uses environment vars, no input
echo "{}" \
  | tempio \
    -template /usr/share/tempio/nginx.gtpl \
    -out /etc/nginx/nginx.conf
