#!/usr/bin/with-contenv bashio
# ==============================================================================
# Backup hmip_address
# ==============================================================================
if bashio::config.true 'hmip_enable' && [ -f /data/hmip_address.conf ]; then
    cp -f /etc/config/hmip_address.conf /data/ || bashio::log.warning "Failed to backup hmip address"
fi
