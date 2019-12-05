#!/usr/bin/env bashio
set -e

CONFIG="/etc/dnsmasq.conf"

bashio::log.info "Configuring dnsmasq..."

if ! bashio::config.is_empty 'interface';
then
    INTERFACE=$(bashio::config 'interface')
    echo "interface=${INTERFACE}" >> "${CONFIG}"
fi

if ! bashio::config.is_empty 'listen_address';
then
    ADDRESS=$(bashio::config 'listen_address')
    echo "listen-address=${ADDRESS}" >> "${CONFIG}"
fi

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

# Create DHCP config
if ! bashio::config.is_empty 'dhcp.lease_time';
then
    LEASE_TIME=$(bashio::config 'dhcp.lease_time')
else
    LEASE_TIME='12h'
fi

if ! bashio::config.is_empty 'dhcp.dns';
then
    DNS=$(bashio::config 'dhcp.dns|join(",")')
    echo "dhcp-option=3,${DNS}" >> "${CONFIG}"
fi

if ! bashio::config.is_empty 'dhcp.domain';
then
    DOMAIN=$(bashio::config 'dhcp.domain')
    echo "domain=${DOMAIN}" >> "${CONFIG}"
fi

if ! bashio::config.is_empty 'dhcp.gateway';
then
    GATEWAY=$(bashio::config 'dhcp.gateway')
    echo "dhcp-option=3,${GATEWAY}" >> "${CONFIG}"
fi

echo "dhcp-authoritative" >> "${CONFIG}"

# Create networks
for network in $(bashio::config 'dhcp.networks|keys'); do
    BROADCAST=$(bashio::config "dhcp.networks[${network}].broadcast")
    NETMASK=$(bashio::config "dhcp.networks[${network}].netmask")
    RANGE_END=$(bashio::config "dhcp.networks[${network}].range_end")
    RANGE_START=$(bashio::config "dhcp.networks[${network}].range_start")
    echo "dhcp-range=${RANGE_START},${RANGE_END},${NETMASK},${BROADCAST},${LEASE_TIME}" >> "${CONFIG}"
done

# Create hosts
for host in $(bashio::config 'dhcp.hosts|keys'); do
    IP=$(bashio::config "dhcp.hosts[${host}].ip")
    MAC=$(bashio::config "dhcp.hosts[${host}].mac")
    NAME=$(bashio::config "dhcp.hosts[${host}].name")
    echo "dhcp-host=${MAC},${IP},${NAME},${LEASE_TIME}" >> "${CONFIG}"
done

# Run dnsmasq
bashio::log.info "Starting dnsmasq..."
exec dnsmasq -C "${CONFIG}" -z < /dev/null
