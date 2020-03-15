#!/usr/bin/env bashio

# shellcheck disable=SC1091
source "/opt/letsencrypt/lib/letsencrypt.sh"

DOMAINS=$(bashio::config 'domains')
KEYFILE=$(bashio::config 'keyfile')
CERTFILE=$(bashio::config 'certfile')

CERT_DIR=$(letsencrypt::cert_dir)

# shellcheck disable=SC2206
DOMAINS_ARRAY=(${DOMAINS[@]})
PRIMARY_DOMAIN="${DOMAINS_ARRAY[0]}"

# copy certs to store
cp "${CERT_DIR}/live/${PRIMARY_DOMAIN}/privkey.pem" "/ssl/$KEYFILE"
cp "${CERT_DIR}/live/${PRIMARY_DOMAIN}/fullchain.pem" "/ssl/$CERTFILE"

# see if we need to restart the core
if bashio::config.exists 'restart_core' && bashio::config.true 'restart_core'; then
    bashio::log.info "Restarting Home Assistant Core"
    bashio::core.restart
fi

if  bashio::config.exists 'restart_addons' && ! bashio::config.is_empty 'restart_addons'; then
    RESTART_ADDONS=$(bashio::config 'restart_addons')
    # restart the set addons
    for addon in $RESTART_ADDONS; do
        bashio::cache.flush_all
        state=$(bashio::addon.state "${addon}")
        if [[ "$state" == "started" ]]; then
            bashio::log.info "Restarting Addon ${addon}"
            bashio::addon.restart "${addon}"
        else
            echo "Not restarting ${addon} because its currently ${state}"
        fi
    done
fi
