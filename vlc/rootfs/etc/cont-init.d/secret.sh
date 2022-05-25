#!/usr/bin/with-contenv bashio
# ==============================================================================
# Create VLC secret
# ==============================================================================

if bashio::fs.file_exists /data/secret; then
    bashio::exit.ok
fi

# Generate password
pwgen 64 1 > /data/secret
