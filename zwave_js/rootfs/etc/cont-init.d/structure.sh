#!/usr/bin/with-contenv bashio
# ==============================================================================
# Setup folder structure
# ==============================================================================
mkdir -p /data/db

if bashio::fs.directory_exists '/data/cache'; then
    mv /data/cache /config/cache
fi

if ! bashio::fs.directory_exists '/config/cache'; then
    mkdir -p /config/cache
fi

if ! bashio::fs.directory_exists '/config/custom_device_configs'; then
    mkdir -p /config/custom_device_configs
fi
