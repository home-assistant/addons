#!/command/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Enable/disable optional services per config
# ==============================================================================
if bashio::config.true 'netbios'; then
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/nmbd
    bashio::log.info "Service nmbd enabled"
else
    rm -f /etc/s6-overlay/s6-rc.d/user/contents.d/nmbd
    bashio::log.info "Service nmbd disabled"
fi

if bashio::config.true 'network_discovery'; then
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/wsdd
    bashio::log.info "Service wsdd enabled"
else
    rm -f /etc/s6-overlay/s6-rc.d/user/contents.d/wsdd
    bashio::log.info "Service wsdd disabled"
fi
