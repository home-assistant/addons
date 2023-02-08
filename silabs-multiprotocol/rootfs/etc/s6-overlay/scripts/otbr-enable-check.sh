#!/usr/bin/with-contenv bashio
# ==============================================================================
# Disable OTBR if not enabled
# ==============================================================================

if bashio::config.false 'otbr_enable'; then
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/otbr-agent
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/otbr-web
    bashio::log.info "The otbr-agent is disabled."
fi

if bashio::config.false 'otbr_web_enable'; then
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/otbr-web
    bashio::log.info "The otbr-web is disabled."
fi
