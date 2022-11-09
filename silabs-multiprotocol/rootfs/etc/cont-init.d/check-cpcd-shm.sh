#!/usr/bin/with-contenv bashio
# ==============================================================================
# Check that no other CPC instance is running on this system
# ==============================================================================
if test -d /dev/shm/cpcd; then
    bashio::log.error "Another CPC daemon running!"
    exit 1
fi
