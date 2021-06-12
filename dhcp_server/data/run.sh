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
    echo "option domain-name \"${DOMAIN}\";"
    echo "option domain-name-servers ${DNS};";
    echo "default-lease-time ${DEFAULT_LEASE};"
    echo "max-lease-time ${MAX_LEASE};"
    echo "authoritative;"
} > "${CONFIG}"

ENABLE_FAILOVER=$(bashio::config 'enable_failover')
if bashio::var.true "${ENABLE_FAILOVER}"
then
    # Create fail over peers
    for peer in $(bashio::config 'failover_peers|keys'); do
        NAME=$(bashio::config "failover_peers[${peer}].name")
        ROLE=$(bashio::config "failover_peers[${peer}].role")
        MCLT=$(bashio::config "failover_peers[${peer}].mclt")
        SPLIT=$(bashio::config "failover_peers[${peer}].split")
        PEER_ADDRESS=$(bashio::config "failover_peers[${peer}].peer_address")
        PEER_PORT=$(bashio::config "failover_peers[${peer}].peer_port")
        MAX_RESPONSE_DELAY=$(bashio::config "failover_peers[${peer}].max_response_delay")
        MAX_UNACKED_UPDATES=$(bashio::config "failover_peers[${peer}].max_unacked_updates")
        LOAD_BALANCE_MAX_SECONDS=$(bashio::config "failover_peers[${peer}].load_balance_max_seconds")

        {
            echo "failover peer \"${NAME}\" {"
            if bashio::var.equals "${ROLE}" "secondary"
            then
                echo "  secondary;"
            else
                echo "  primary;"
                echo "  mclt ${MCLT};"
                echo "  split ${SPLIT};"
            fi
            echo "  address $(bashio::addon.ip_address);"
            echo "  port 647;"
            echo "  peer address ${PEER_ADDRESS};"
            echo "  peer port ${PEER_PORT:-647};"
            echo "  max-response-delay ${MAX_RESPONSE_DELAY};"
            echo "  max-unacked-updates ${MAX_UNACKED_UPDATES};"
            echo "  load balance max seconds ${LOAD_BALANCE_MAX_SECONDS};"
            echo "}"
        } >> "${CONFIG}"
    done
fi

# Create networks
for network in $(bashio::config 'networks|keys'); do
    BROADCAST=$(bashio::config "networks[${network}].broadcast")
    GATEWAY=$(bashio::config "networks[${network}].gateway")
    INTERFACE=$(bashio::config "networks[${network}].interface")
    NETMASK=$(bashio::config "networks[${network}].netmask")
    RANGE_END=$(bashio::config "networks[${network}].range_end")
    RANGE_START=$(bashio::config "networks[${network}].range_start")
    SUBNET=$(bashio::config "networks[${network}].subnet")
    FAILOVER_PEER=$(bashio::config "networks[${network}].failover_peer")

    {
        echo "subnet ${SUBNET} netmask ${NETMASK} {"
        echo "  interface ${INTERFACE};"
        echo "  option routers ${GATEWAY};"
        echo "  option broadcast-address ${BROADCAST};"
        if bashio::var.equals "${FAILOVER_PEER}" "null" || \
           bashio::var.is_empty "${FAILOVER_PEER}" || \
           bashio::var.false "${ENABLE_FAILOVER}"
        then
            echo "  range ${RANGE_START} ${RANGE_END};"
        else
            echo "  pool {"
            echo "    failover peer \"${FAILOVER_PEER}\";"
            echo "    range ${RANGE_START} ${RANGE_END};"
            echo "  }"
        fi
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

# Write configuration to log and start DHCP server
bashio::log.info "Starting DHCP server with the following configuration:"
cat "${CONFIG}"
echo ""

exec /usr/sbin/dhcpd \
    -4 -f -d --no-pid \
    -lf "${LEASES}" \
    -cf "${CONFIG}" \
    < /dev/null
