#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Disable OTBR if not enabled
# ==============================================================================

if bashio::config.false 'otbr_enable'; then
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/otbr-agent
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/otbr-web
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/otbr-agent-rest-discovery
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/mdns
    bashio::log.info "The otbr-agent is disabled."
    bashio::exit.ok
fi

if bashio::var.has_value "$(bashio::addon.port 8080)" \
     && bashio::var.has_value "$(bashio::addon.port 8081)"; then
    bashio::log.info "Web UI and REST API port are exposed, starting otbr-web."
else
    rm /etc/s6-overlay/s6-rc.d/user/contents.d/otbr-web
    bashio::log.info "The otbr-web is disabled."
fi
