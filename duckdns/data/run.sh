#!/usr/bin/env bashio

CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir

# Let's encrypt
LE_UPDATE="0"

# DuckDNS
if bashio::config.has_value "ipv4"; then IPV4=$(bashio::config 'ipv4'); else IPV4=""; fi
if bashio::config.has_value "ipv6"; then IPV6=$(bashio::config 'ipv6'); else IPV6=""; fi
TOKEN=$(bashio::config 'token')
DOMAINS=$(bashio::config 'domains | join(",")')
WAIT_TIME=$(bashio::config 'seconds')
ALGO=$(bashio::config 'lets_encrypt.algo')

# Function that performe a renew
function le_renew() {
    local domain_args=()
    local domains=''
    local aliases=''

    domains=$(bashio::config 'domains')

    # Prepare domain for Let's Encrypt
    for domain in ${domains}; do
        for alias in $(jq --raw-output --exit-status "[.aliases[]|{(.alias):.domain}]|add.\"${domain}\" | select(. != null)" /data/options.json) ; do
            aliases="${aliases} ${alias}"
        done
    done

    aliases="$(echo "${aliases}" | tr ' ' '\n' | sort | uniq)"

    bashio::log.info "Renew certificate for domains: $(echo -n "${domains}") and aliases: $(echo -n "${aliases}")"

    for domain in $(echo "${domains}" "${aliases}" | tr ' ' '\n' | sort | uniq); do
        domain_args+=("--domain" "${domain}")
    done

    dehydrated --cron --algo "${ALGO}" --hook ./hooks.sh --challenge dns-01 "${domain_args[@]}" --out "${CERT_DIR}" --config "${WORK_DIR}/config" || true
    LE_UPDATE="$(date +%s)"
}

# Register/generate certificate if terms accepted
if bashio::config.true 'lets_encrypt.accept_terms'; then
    # Init folder structs
    mkdir -p "${CERT_DIR}"
    mkdir -p "${WORK_DIR}"

    # Clean up possible stale lock file
    if [ -e "${WORK_DIR}/lock" ]; then
        rm -f "${WORK_DIR}/lock"
        bashio::log.warning "Reset dehydrated lock file"
    fi

    # Generate new certs
    if [ ! -d "${CERT_DIR}/live" ]; then
        # Create empty dehydrated config file so that this dir will be used for storage
        touch "${WORK_DIR}/config"

        dehydrated --register --accept-terms --config "${WORK_DIR}/config"
    fi
fi

# Run duckdns
while true; do

    [[ ${IPV4} != *:/* ]] && ipv4=${IPV4} || ipv4=$(curl -s -m 10 "${IPV4}")
    [[ ${IPV6} != *:/* ]] && ipv6=${IPV6} || ipv6=$(curl -s -m 10 "${IPV6}")

    if answer="$(curl -s "https://www.duckdns.org/update?domains=${DOMAINS}&token=${TOKEN}&ip=${ipv4}&ipv6=${ipv6}&verbose=true")" && [ "${answer}" != 'KO' ]; then
        bashio::log.info "${answer}"
    else
        bashio::log.warning "${answer}"
    fi

    now="$(date +%s)"
    if bashio::config.true 'lets_encrypt.accept_terms' && [ $((now - LE_UPDATE)) -ge 43200 ]; then
        le_renew
    fi

    sleep "${WAIT_TIME}"
done
