#!/usr/bin/with-contenv bashio

# ==============================================================================
# Create VLC secret
# ==============================================================================

# Generate password

if bashio::fs.file_exists /data/telnet-secret; then
    bashio::exit.ok
else
    pwgen 64 1 > /data/telnet-secret
fi
