#!/usr/bin/env bashio
set -e

CONFIG="/etc/dnsmasq.conf"

bashio::log.info "Configuring dnsmasq..."

if bashio::config.has_value 'interface';
then
    INTERFACE=$(bashio::config 'interface')
    echo "interface=${INTERFACE}" >> "${CONFIG}"
fi

if bashio::config.has_value 'listen_address'; then
    ADDRESS=$(bashio::config 'listen_address')
    echo "listen-address=${ADDRESS}" >> "${CONFIG}"
fi

# Get lease time
LEASE_TIME='12h'
if bashio::config.has_value 'lease_time'; then
    LEASE_TIME=$(bashio::config 'lease_time')
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
    if bashio::config.has_value "hosts[${host}].mac"; then
        MAC=$(bashio::config "hosts[${host}].mac")
        echo "dhcp-host=${MAC},${IP},${HOST},${LEASE_TIME}" >> "${CONFIG}"
    fi
done

if bashio::config.has_value 'domain'; then
    DOMAIN=$(bashio::config 'domain')
    echo "domain=${DOMAIN}" >> "${CONFIG}"
fi

if bashio::config.has_value 'gateway'; then
    GATEWAY=$(bashio::config 'gateway')
    echo "dhcp-option=3,${GATEWAY}" >> "${CONFIG}"
fi

echo "dhcp-authoritative" >> "${CONFIG}"
echo "dhcp-broadcast" >> "${CONFIG}"

# Create networks
for network in $(bashio::config 'networks|keys'); do
    BROADCAST=$(bashio::config "networks[${network}].broadcast")
    NETMASK=$(bashio::config "networks[${network}].netmask")
    RANGE_END=$(bashio::config "networks[${network}].range_end")
    RANGE_START=$(bashio::config "networks[${network}].range_start")
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
