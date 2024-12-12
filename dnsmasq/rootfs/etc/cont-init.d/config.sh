#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# DNSMASQ config
# ==============================================================================

CONFIG="/etc/dnsmasq.conf"
bashio::log.info "Configuring dnsmasq..."
tempio \
    -conf /data/options.json \
    -template /usr/share/tempio/dnsmasq.config \
    -out "${CONFIG}"

