#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Custom S6 stage2 hook — runs before services.d start
# ==============================================================================

bashio::log.info "Running enable-check hook..."

if ! bashio::config.true 'ota_update.bosch'; then
    bashio::log.info "Bosch OTA updates disabled — removing otau-bosch service"
    rm -rf /etc/services.d/otau-bosch
fi

if ! bashio::config.true 'ota_update.ikea'; then
    bashio::log.info "IKEA OTA updates disabled — removing otau-ikea service"
    rm -rf /etc/services.d/otau-ikea
fi

if ! bashio::config.true 'ota_update.ledvance'; then
    bashio::log.info "LEDVANCE OTA updates disabled — removing otau-ledvance service"
    rm -rf /etc/services.d/otau-ledvance
fi

bashio::log.info "Enable-check hook finished."
