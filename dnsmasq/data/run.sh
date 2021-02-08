#!/usr/bin/env bashio
set -e

CONFIG="/etc/dnsmasq.conf"

bashio::log.info "Configuring dnsmasq..."

# Add default forward servers
for server in $(bashio::config 'defaults'); do
    echo "server=${server}" >> "${CONFIG}"
done

# Create domain forwards
for forward in $(bashio::config 'forwards|keys'); do
    DOMAIN=$(bashio::config "forwards[${forward}].domain")
    SERVER=$(bashio::config "forwards[${forward}].server")

    echo "server=/${DOMAIN}/${SERVER}" >> "${CONFIG}"
done

# Create static hosts
for host in $(bashio::config 'hosts|keys'); do
    HOST=$(bashio::config "hosts[${host}].host")
    IP=$(bashio::config "hosts[${host}].ip")

    echo "address=/${HOST}/${IP}" >> "${CONFIG}"
done

# Create static srv-hosts
for srvhost in $(bashio::config 'srv-hosts|keys'); do
    SRV=$(bashio::config "srv-hosts[${srvhost}].srv")
    HOST=$(bashio::config "srv-hosts[${srvhost}].host")
    PORT=$(bashio::config "srv-hosts[${srvhost}].port")
    PRIORITY=$(bashio::config "srv-hosts[${srvhost}].priority")
    WEIGHT=$(bashio::config "srv-hosts[${srvhost}].weight")

    echo "srv-host=${SRV},${HOST},${PORT},${PRIORITY},${WEIGHT}" >> "${CONFIG}"
done

# Create extra dnsmasq options
for extra in $(bashio::config 'extra-options|keys'); do
    DNSMASQ_EXTRA_OPTION=$(bashio::config "extra-options[${extra}].option")

    echo "${DNSMASQ_EXTRA_OPTION}" >> "${CONFIG}"
done

# Run dnsmasq
bashio::log.info "Starting dnsmasq..."
exec dnsmasq -C "${CONFIG}" -z < /dev/null
