#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
DEVICES=$(jq --raw-output '.devices | length' $CONFIG_PATH)

echo "[Info] Initialize the tellstick configuration"

# User access
echo "user = \"root\"" > /etc/tellstick.conf
echo "group = \"plugdev\"" >> /etc/tellstick.conf
echo "ignoreControllerConfirmation = \"false\"" >> /etc/tellstick.conf

# devices
for (( i=0; i < "$DEVICES"; i++ )); do
    DEV_ID=$(jq --raw-output ".devices[$i].id" $CONFIG_PATH)
    DEV_NAME=$(jq --raw-output ".devices[$i].name" $CONFIG_PATH)
    DEV_PROTO=$(jq --raw-output ".devices[$i].protocol" $CONFIG_PATH)
    DEV_MODEL=$(jq --raw-output ".devices[$i].model // empty" $CONFIG_PATH)
    ATTR_HOUSE=$(jq --raw-output ".devices[$i].house // empty" $CONFIG_PATH)
    ATTR_CODE=$(jq --raw-output ".devices[$i].code // empty" $CONFIG_PATH)
    ATTR_UNIT=$(jq --raw-output ".devices[$i].unit // empty" $CONFIG_PATH)
    ATTR_FADE=$(jq --raw-output ".devices[$i].fade // empty" $CONFIG_PATH)
  
    (
        echo ""
        echo "device {"
        echo "  id = $DEV_ID"
        echo "  name = \"$DEV_NAME\""
        echo "  protocol = \"$DEV_PROTO\""
        
        if [ ! -z "$DEV_MODEL" ]; then
            echo "  model = \"$DEV_MODEL\""
        fi
        
        if [ ! -z "$ATTR_HOUSE" ] || [ ! -z "$ATTR_CODE" ] || [ ! -z "$ATTR_UNIT" ] || [ ! -z "$ATTR_FADE" ]; then
            echo "  parameters {"
            
            if [ ! -z "$ATTR_HOUSE" ]; then
                echo "    house = \"$ATTR_HOUSE\""
            fi
            if [ ! -z "$ATTR_CODE" ]; then
                echo "    code = \"$ATTR_CODE\""
            fi
            if [ ! -z "$ATTR_UNIT" ]; then
                echo "    unit = \"$ATTR_UNIT\""
            fi
            if [ ! -z "$ATTR_FADE" ]; then
                echo "    fade = \"$ATTR_FADE\""
            fi
            
            echo "  }"
        fi
        
        echo "}"
    ) >> /etc/tellstick.conf
done

echo "[Info] Exposing sockets and loading service"

# Expose the unix socket to internal network
socat TCP-LISTEN:50800,reuseaddr,fork UNIX-CONNECT:/tmp/TelldusClient &
socat TCP-LISTEN:50801,reuseaddr,fork UNIX-CONNECT:/tmp/TelldusEvents &

# Run telldus-core daemon in the background
/usr/local/sbin/telldusd --nodaemon < /dev/null &

# Listen for input to tdtool
echo "[Info] Starting event listener"
while read -r input; do
    # parse JSON value
    funct="$(echo "$input" | jq --raw-output '.function')"
    devid="$(echo "$input" | jq --raw-output '.device // empty')"
    echo "[Info] Read $funct / $devid"
    
    if ! msg="$(tdtool "--$funct" "$devid")"; then
    	echo "[Error] TellStick $funct fails -> $msg"
    else
        echo "[Info] TellStick $funct success -> $msg"
    fi
done
