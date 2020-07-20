#!/usr/bin/with-contenv bashio
# ==============================================================================
# Configure VNC for use with deCONZ
# ==============================================================================

# Check if VNC is enabled
VNC_PORT="$(bashio::addon.port 5900)"
if ! bashio::var.has_value "${VNC_PORT}"; then
  # VNC is not enabled, skip this.
  bashio::exit.ok
fi

# Require password when VNC is enabled
if ! bashio::config.has_value 'vnc_password'; then
    bashio::exit.nok "VNC has been enabled, but no password has been set!"
fi

VNC_PASSWORD=$(bashio::config 'vnc_password')
echo "${VNC_PASSWORD}" | tigervncpasswd -f > /root/.vncpasswd