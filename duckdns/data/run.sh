#!/usr/bin/env bashio

CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir

# Let's encrypt
LE_UPDATE="0"

# DuckDNS
IPV4=$(bashio::config 'ipv4')
IPV6=$(bashio::config 'ipv6')
TOKEN=$(bashio::config 'token')
DOMAINS=$(bashio::config 'domains|join(",")')
WAIT_TIME=$(bashio::config 'seconds')

# Function that performe a renew
function le_renew() {
    local domain_args=()
    local domains
  
    domains=$(bashio::config 'domains')

    # Prepare domain for Let's Encrypt
    for domain in $domains; do
        domain_args+=("--domain" "$domain")
    done
    
    dehydrated --cron --hook ./hooks.sh --challenge dns-01 "${domain_args[@]}" --out "$CERT_DIR" --config "$WORK_DIR/config" || true
    LE_UPDATE="$(date +%s)"
}

# Register/generate certificate if terms accepted
if bashio::config.true 'lets_encrypt.accept_terms'; then
    # Init folder structs
    mkdir -p "$CERT_DIR"
    mkdir -p "$WORK_DIR"
    
    # Generate new certs
    if [ ! -d "$CERT_DIR/live" ]; then
        # Create empty dehydrated config file so that this dir will be used for storage
        touch "$WORK_DIR/config"
        
        dehydrated --register --accept-terms --config "$WORK_DIR/config"
    fi
fi

# Run duckdns
while true; do
    if answer="$(curl -sk "https://www.duckdns.org/update?domains=$DOMAINS&token=$TOKEN&ip=$IPV4&ipv6=$IPV6&verbose=true")"; then
        bashio::log.info "$answer"
    else
        bashio::log.warning "$answer"
    fi
    
    now="$(date +%s)"
    if bashio::config.true 'lets_encrypt.accept_terms' && [ $((now - LE_UPDATE)) -ge 43200 ]; then
        le_renew
    fi
    
    sleep "$WAIT_TIME"
done
