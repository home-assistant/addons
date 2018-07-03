#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

PLAIN=$(jq --raw-output ".plain" $CONFIG_PATH)
PLAIN_WS=$(jq --raw-output ".plain_websockets" $CONFIG_PATH)
SSL=$(jq --raw-output ".ssl" $CONFIG_PATH)
SSL_WS=$(jq --raw-output ".ssl_websockets" $CONFIG_PATH)
LOGINS=$(jq --raw-output ".logins | length" $CONFIG_PATH)
ANONYMOUS=$(jq --raw-output ".anonymous" $CONFIG_PATH)
KEYFILE=$(jq --raw-output ".keyfile" $CONFIG_PATH)
CERTFILE=$(jq --raw-output ".certfile" $CONFIG_PATH)
CUSTOMIZE_ACTIVE=$(jq --raw-output ".customize.active" $CONFIG_PATH)

PLAIN_CONFIG="
listener 1883
protocol mqtt
"

PLAIN_WS_CONFIG="
listener 1884
protocol websockets
"

SSL_CONFIG="
listener 8883
protocol mqtt
cafile /ssl/$CERTFILE
certfile /ssl/$CERTFILE
keyfile /ssl/$KEYFILE
"

SSL_WS_CONFIG="
listener 8884
protocol websockets
cafile /ssl/$CERTFILE
certfile /ssl/$CERTFILE
keyfile /ssl/$KEYFILE
"

# Add plain configs
if [ "$PLAIN" == "true" ]; then
    echo "$PLAIN_CONFIG" >> /etc/mosquitto.conf
fi
if [ "$PLAIN_WS" == "true" ]; then
    echo "$PLAIN_WS_CONFIG" >> /etc/mosquitto.conf
fi

# Add ssl configs
if [ "$SSL" == "true" ]; then
    echo "$SSL_CONFIG" >> /etc/mosquitto.conf
fi
if [ "$SSL_WS" == "true" ]; then
    echo "$SSL_WS_CONFIG" >> /etc/mosquitto.conf
fi

# Allow anonymous connections
if [ "$ANONYMOUS" == "false" ]; then
    sed -i "s/#allow_anonymous/allow_anonymous/g" /etc/mosquitto.conf
fi

# Allow customize configs from share
if [ "$CUSTOMIZE_ACTIVE" == "true" ]; then
    CUSTOMIZE_FOLDER=$(jq --raw-output ".customize.folder" $CONFIG_PATH)
    sed -i "s|#include_dir .*|include_dir /share/$CUSTOMIZE_FOLDER|g" /etc/mosquitto.conf
fi

# Generate user data
if [ "$LOGINS" -gt "0" ]; then
    sed -i "s/#password_file/password_file/g" /etc/mosquitto.conf
    rm -f /data/users.db || true
    touch /data/users.db

    for (( i=0; i < "$LOGINS"; i++ )); do
        USERNAME=$(jq --raw-output ".logins[$i].username" $CONFIG_PATH)
        PASSWORD=$(jq --raw-output ".logins[$i].password" $CONFIG_PATH)

        mosquitto_passwd -b /data/users.db "$USERNAME" "$PASSWORD"
    done
fi

# start server
exec mosquitto -c /etc/mosquitto.conf < /dev/null
