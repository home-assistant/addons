#!/command/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Enable/disable nmbd service per config
# ==============================================================================
if bashio::config.true 'netbios'; then
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/nmbd
    bashio::log.info "Service nmbd enabled"
else
    rm -f /etc/s6-overlay/s6-rc.d/user/contents.d/nmbd
    bashio::log.info "Service nmbd disabled"
fi
