#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

DEFAULT_LEASE=$(jq --raw-output '.default_lease' $CONFIG_PATH)
MAX_LEASE=$(jq --raw-output '.max_lease' $CONFIG_PATH)
DOMAIN=$(jq --raw-output '.domain' $CONFIG_PATH)
DNS=$(jq --raw-output '.dns | join(", ")' $CONFIG_PATH)
NETWORKS=$(jq --raw-output '.networks | length' $CONFIG_PATH)
HOSTS=$(jq --raw-output '.hosts | length' $CONFIG_PATH)

sed -i "s/%%DOMAIN%%/$DOMAIN/g" /etc/dhcpd.conf
sed -i "s/%%DNS_SERVERS%%/$DNS/g" /etc/dhcpd.conf
sed -i "s/%%DEFAULT_LEASE%%/$DEFAULT_LEASE/g" /etc/dhcpd.conf
sed -i "s/%%MAX_LEASE%%/$MAX_LEASE/g" /etc/dhcpd.conf

# Create networks
for (( i=0; i < "$NETWORKS"; i++ )); do
    SUBNET=$(jq --raw-output ".networks[$i].subnet" $CONFIG_PATH)
    NETMASK=$(jq --raw-output ".networks[$i].netmask" $CONFIG_PATH)
    RANGE_START=$(jq --raw-output ".networks[$i].range_start" $CONFIG_PATH)
    RANGE_END=$(jq --raw-output ".networks[$i].range_end" $CONFIG_PATH)
    BROADCAST=$(jq --raw-output ".networks[$i].broadcast" $CONFIG_PATH)
    GATEWAY=$(jq --raw-output ".networks[$i].gateway" $CONFIG_PATH)
    INTERFACE=$(jq --raw-output ".networks[$i].interface" $CONFIG_PATH)

    {
        echo "subnet $SUBNET netmask $NETMASK {"
        echo "  range $RANGE_START $RANGE_END;"
        echo "  interface $INTERFACE;"
        echo "  option routers $GATEWAY;"
        echo "  option broadcast-address $BROADCAST;"
        echo "}"
    } >> /etc/dhcpd.conf
done

# Create hosts
for (( i=0; i < "$HOSTS"; i++ )); do
    MAC=$(jq --raw-output ".hosts[$i].mac" $CONFIG_PATH)
    NAME=$(jq --raw-output ".hosts[$i].name" $CONFIG_PATH)
    IP=$(jq --raw-output ".hosts[$i].ip" $CONFIG_PATH)

    {
        echo "host $NAME {"
        echo "  hardware ethernet $MAC;"
        echo "  fixed-address $IP;"
        echo "  option host-name \"$NAME\";"
        echo "}"
    } >> /etc/dhcpd.conf
done

# Create database
if [ ! -f /data/dhcpd.lease ]; then
    touch /data/dhcpd.lease
fi

# run dhcp server
exec /usr/sbin/dhcpd -4 -f -d --no-pid -lf /data/dhcpd.lease -cf /etc/dhcpd.conf < /dev/null
