#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

DEFAULTS=$(jq --raw-output '.defaults[]' $CONFIG_PATH)
FORWARDS=$(jq --raw-output '.forwards | length' $CONFIG_PATH)
HOSTS=$(jq --raw-output '.hosts | length' $CONFIG_PATH)
INTERFACE=$(jq --raw-output '.interface' $CONFIG_PATH)

# Bind to interface
if [ -z "$INTERFACE" ]; then
    echo "interface=$INTERFACE" >> /etc/dnsmasq.conf
fi

# Add default forward servers
for line in $DEFAULTS; do
    echo "server=$line" >> /etc/dnsmasq.conf
done

# Create domain forwards
for (( i=0; i < "$FORWARDS"; i++ )); do
    DOMAIN=$(jq --raw-output ".forwards[$i].domain" $CONFIG_PATH)
    SERVER=$(jq --raw-output ".forwards[$i].server" $CONFIG_PATH)

    echo "server=/$DOMAIN/$SERVER" >> /etc/dnsmasq.conf
done

# Create static hosts
for (( i=0; i < "$HOSTS"; i++ )); do
    HOST=$(jq --raw-output ".forwards[$i].host" $CONFIG_PATH)
    IP=$(jq --raw-output ".forwards[$i].ip" $CONFIG_PATH)

    echo "address=/$HOST/$IP" >> /etc/dnsmasq.conf
done

# run dnsmasq
exec dnsmasq -C /etc/dnsmasq.conf -z < /dev/null
