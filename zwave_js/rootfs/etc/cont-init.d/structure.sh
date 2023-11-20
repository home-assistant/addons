#!/usr/bin/with-contenv bashio
# ==============================================================================
# Setup folder structure
# ==============================================================================
mkdir -p /data/db

if bashio::fs.directory_exists '/data/cache'; then
    bashio::log.info "Migrating 'cache' folder from private storage to /addon_configs/core_zwave_js"
    mv /data/cache /config/cache
fi

if ! bashio::fs.directory_exists '/config/cache'; then
    mkdir -p /config/cache
fi
