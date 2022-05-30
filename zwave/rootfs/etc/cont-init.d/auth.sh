#!/usr/bin/with-contenv bashio
# ==============================================================================
# Setup auth data
# ==============================================================================
declare homeassistant_pw
declare ozw_pw

AUTH_FILE=/data/auth.db

if bashio::fs.file_exists ${AUTH_FILE}; then
    bashio::log.info "Auth database exists"
    bashio::exit.ok
fi

homeassistant_pw="$(pwgen 64 1)"
ozw_pw="$(pwgen 64 1)"

bashio::log.info "Setup mqtt auth db"

(
    echo "ozw:${ozw_pw}"
    echo "homeassistant:${homeassistant_pw}"
) > "${AUTH_FILE}"

# Encrypt data
mosquitto_passwd -U ${AUTH_FILE}

config=$(bashio::var.json \
    ozw_password "${ozw_pw}" \
    homeassistant_password "${homeassistant_pw}" \
)

echo "$config" > /data/auth.json
