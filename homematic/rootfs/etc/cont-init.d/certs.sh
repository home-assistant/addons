#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configure NGINX for use with ReGaHss
# ==============================================================================

if [ -f /data/server.pem ]; then
    cp -f /data/server.pem /etc/config/server.pem
else
    openssl req -new -x509 -nodes -keyout /etc/config/server.pem -out /etc/config/server.pem -days 3650 -subj "/C=DE/O=HomeMatic/OU=HomeAssistant/CN=$(hostname)"
    cp -f /etc/config/server.pem /data/server.pem
fi
