#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
DEVICES=$(jq --raw-output '.forwards | length' $CONFIG_PATH)

echo "[Info] Initialize the tellstick configuration"

# User access
echo "user = \"root\"" > /etc/tellstick.conf

# devices
for (for (( i=0; i < "$DEVICES"; i++ )); do
    DEV_ID = $(jq --raw-output ".DEVICES[$i].id" $CONFIG_PATH)
    DEV_NAME = $(jq --raw-output ".DEVICES[$i].name" $CONFIG_PATH)
    DEV_PROTO = $(jq --raw-output ".DEVICES[$i].protocol" $CONFIG_PATH)
    DEV_MODEL = $(jq --raw-output ".DEVICES[$i].model // emty" $CONFIG_PATH)
    ATTR_HOUSE = $(jq --raw-output ".DEVICES[$i].house // emty" $CONFIG_PATH)
    ATTR_CODE = $(jq --raw-output ".DEVICES[$i].code // emty" $CONFIG_PATH)
    ATTR_UNIT = $(jq --raw-output ".DEVICES[$i].unit // emty" $CONFIG_PATH)
  
    (
        echo ""
        echo "device {"
        echo "  id = $DEV_ID"
        echo "  name = \"$DEV_NAME\""
        echo "  protocol = \"$DEV_PROTO\""
        
        if [ ! -z "$DEV_MODEL" ]; then
            echo "  model = \"$DEV_MODEL\""
        fi
        
        if [ ! -z "$ATTR_HOUSE" ] || [ ! -z "$ATTR_CODE" ] || [ ! -z "$ATTR_UNIT" ]; then
            echo "  parameters {"
            
            if [ ! -z "$ATTR_HOUSE" ]; then
                echo "    house = \"$ATTR_HOUSE\""
            if
            if [ ! -z "$ATTR_CODE" ]; then
                echo "    code = \"$ATTR_CODE\""
            if
            if [ ! -z "$ATTR_UNIT" ]; then
                echo "    code = \"$ATTR_UNIT\""
            if
            
            echo "  }"
        if
        
        echo "}"
    ) >> /etc/tellstick.conf
done

echo "[Info] Run telldusd & socat"

# Expose the unix socket to internal network
socat TCP-LISTEN:50800,reuseaddr,fork UNIX-CONNECT:/tmp/TelldusClient &
socat TCP-LISTEN:50801,reuseaddr,fork UNIX-CONNECT:/tmp/TelldusEvents &

exec /usr/local/sbin/telldusd --nodaemon < /dev/null
