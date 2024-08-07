#!/usr/bin/with-contenv bashio
set -e

CONFIG="/etc/dhcpd.conf"
LEASES="/data/dhcpd.lease"

bashio::log.info "Creating DHCP configuration..."

# Create main config
DEFAULT_LEASE=$(bashio::config 'default_lease')
DOMAIN=$(bashio::config 'domain')
MAX_LEASE=$(bashio::config 'max_lease')

{
    echo "option domain-name \"${DOMAIN}\";"
    echo "default-lease-time ${DEFAULT_LEASE};"
    echo "max-lease-time ${MAX_LEASE};"
    echo "authoritative;"
} > "${CONFIG}"

# Create DNS Server List
if [ "$(bashio::config 'dns')" ]
then
    DNS=$(bashio::config 'dns|join(", ")')
    {
        echo "option domain-name-servers ${DNS};";
    } >> "${CONFIG}"
fi


# Create NTP Server List
if [ "$(bashio::config 'ntp')" ]
then
    NTP=$(bashio::config 'ntp|join(", ")')
    {
        echo "option ntp-servers ${NTP};";
    } >> "${CONFIG}"
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

    {
        echo "subnet ${SUBNET} netmask ${NETMASK} {"
        echo "  interface ${INTERFACE};"
        echo "  range ${RANGE_START} ${RANGE_END};"
        echo "  option routers ${GATEWAY};"
        echo "  option broadcast-address ${BROADCAST};"
        echo "}"
    } >> "${CONFIG}"
done

# Create DHCP Hosts by enumerating Host List & Keys (IP, MAC, Name, or DHCP Option)
for host in $(bashio::config 'hosts|keys'); do
    NAME=$(bashio::config "hosts[${host}].name")

    {
        echo "host ${NAME} {"

    # Iterate all Hosts
    for key in $(bashio::config "hosts[${host}]|keys"); do
        VALUE=$(bashio::config "hosts[${host}].${key}")

        # Validate: Named options
        if [[ "${key}" == "ip" ]]; then
            echo "  fixed-address ${VALUE};"
        elif [[ "${key}" == "mac" ]]; then
            echo "  hardware ethernet ${VALUE};"
        
        # Validate: Numeric DHCP Option
        elif [[ "${key}" =~ ^[0-9]+$ ]]; then
            if (( key > 0 && key < 255 )); then
                echo "  option ${key} ${VALUE};"
            fi
        fi
    done

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
