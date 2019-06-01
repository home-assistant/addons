#!/usr/bin/env bashio
set -e

CONFIG="/etc/dhcpd.conf"
LEASES="/data/dhcpd.lease"

bashio::log.info "Creating DHCP configuration..."

# Create main config
DEFAULT_LEASE=$(bashio::config 'default_lease')
DNS=$(bashio::config 'dns|join(", ")')
DOMAIN=$(bashio::config 'domain')
MAX_LEASE=$(bashio::config 'max_lease')

{
    echo "option domain-name ${DOMAIN};"
    echo "option domain-name-servers ${DNS};";
    echo "default-lease-time ${DEFAULT_LEASE};"
    echo "max-lease-time ${MAX_LEASE};"
    echo "authoritative;"
} > "${CONFIG}"

# Create networks
for network in $(bashio::config 'networks|keys'); do
    BROADCAST=$(bashio::config "networks[${network}].broadcast")
    GATEWAY=$(bashio::config "networks[${network}].gateway")
    INTERFACE=$(bashio::config "networks[${network}].interface")
    NETMASK=$(bashio::config "networks[${network}].netmask")
    RANGE_END=$(bashio::config "networks[${network}].range_end")
    RANGE_START=$(bashio::config "networks[${network}].range_start")
    SUBNET=$(bashio::config "networks[${network}].subnet")

    {
        echo "subnet ${SUBNET} netmask ${NETMASK} {"
        echo "  interface ${INTERFACE};"
        echo "  range ${RANGE_START} ${RANGE_END};"
        echo "  option routers ${GATEWAY};"
        echo "  option broadcast-address ${BROADCAST};"
        echo "}"
    } >> "${CONFIG}"
done

# Create hosts
for host in $(bashio::config 'hosts|keys'); do
    IP=$(bashio::config "hosts[${host}].ip")
    MAC=$(bashio::config "hosts[${host}].mac")
    NAME=$(bashio::config "hosts[${host}].name")

    {
        echo "host ${NAME} {"
        echo "  hardware ethernet ${MAC};"
        echo "  fixed-address ${IP};"
        echo "  option host-name \"${NAME}\";"
        echo "}"
    } >> "${CONFIG}"
done

# Create database
if ! bashio::fs.file_exists "${LEASES}"; then
    touch "${LEASES}"
fi

# Start DHCP server
bashio::log.info "Starting DHCP server..."
exec /usr/sbin/dhcpd \
    -4 -f -d --no-pid \
    -lf "${LEASES}" \
    -cf "${CONFIG}" \
    < /dev/null
