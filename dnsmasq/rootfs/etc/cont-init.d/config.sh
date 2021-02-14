#!/usr/bin/with-contenv /usr/lib/bashio/bashio
# ==============================================================================
# DNSMASQ config
# ==============================================================================

CONFIG="/etc/dnsmasq.conf"
bashio::log.info "Configuring dnsmasq..."
tempio \
    -conf /data/options.json \
    -template /usr/share/tempio/dnsmasq.config \
    -out "${CONFIG}"

