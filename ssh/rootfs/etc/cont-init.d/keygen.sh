#!/usr/bin/with-contenv bashio
# ==============================================================================
# SSH Host keys
# ==============================================================================
KEYS_PATH=/data/host_keys

if ! bashio::fs.directory_exists "${KEYS_PATH}"; then
    bashio::log.info "Generating host keys..."

    mkdir -p "${KEYS_PATH}"
    ssh-keygen -A || bashio::exit.nok "Failed to create host keys!"
    cp -fp /etc/ssh/ssh_host* "${KEYS_PATH}/"
else
    bashio::log.info "Restoring host keys..."
    cp -fp "${KEYS_PATH}"/* /etc/ssh/
fi
