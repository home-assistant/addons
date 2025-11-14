#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Custom S6 stage2 hook — runs before services.d start
# ==============================================================================
if ! bashio::config.true 'ota_update.bosch'; then
    bashio::log.info "Bosch OTA update is disabled."
    rm /etc/services.d/otau-bosch
fi

if ! bashio::config.true 'ota_update.ikea'; then
    bashio::log.info "IKEA OTA update is disabled."
    rm /etc/services.d/otau-ikea
fi

if ! bashio::config.true 'ota_update.ledvance'; then
    bashio::log.info "OSRAM/LEDVANCE OTA update is disabled."
    rm /etc/services.d/otau-ledvance
fi
