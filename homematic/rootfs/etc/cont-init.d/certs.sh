#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configure NGINX for use with ReGaHss
# ==============================================================================
openssl req -new -x509 -nodes -keyout /etc/config/server.pem -out /etc/config/server.pem -days 3650 -subj "/C=DE/O=HomeMatic/OU=Hass.io/CN=$(hostname)"
