#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Select OTBR version and enable mDNSResponder for stable mode
# ==============================================================================

if bashio::config.true 'beta'; then
    bashio::log.info "Beta mode enabled, using OpenThread built-in mDNS."

    ln -sf "/opt/otbr-beta/sbin/otbr-agent" /usr/sbin/otbr-agent
    ln -sf "/opt/otbr-beta/sbin/otbr-web" /usr/sbin/otbr-web
    ln -sf "/opt/otbr-beta/sbin/ot-ctl" /usr/sbin/ot-ctl
else
    bashio::log.info "Stable mode, enabling mDNSResponder."

    touch /etc/s6-overlay/s6-rc.d/user/contents.d/mdns
    touch /etc/s6-overlay/s6-rc.d/otbr-agent/dependencies.d/mdns

    ln -sf "/opt/otbr-stable/sbin/otbr-agent" /usr/sbin/otbr-agent
    ln -sf "/opt/otbr-stable/sbin/otbr-web" /usr/sbin/otbr-web
    ln -sf "/opt/otbr-stable/sbin/ot-ctl" /usr/sbin/ot-ctl
    ln -sf "/opt/otbr-stable/sbin/mdnsd" /usr/sbin/mdnsd
fi

# ==============================================================================
# Enable socat-otbr-tcp service if needed
# ==============================================================================

if bashio::config.has_value 'network_device'; then
    touch /etc/s6-overlay/s6-rc.d/user/contents.d/socat-otbr-tcp
    touch /etc/s6-overlay/s6-rc.d/otbr-agent/dependencies.d/socat-otbr-tcp
    bashio::log.info "Enabled socat-otbr-tcp."
fi
