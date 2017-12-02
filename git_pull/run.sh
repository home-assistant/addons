#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

DEPLOYMENT_KEY=$(jq --raw-output ".deployment_key[]" $CONFIG_PATH)
DEPLOYMENT_KEY_PROTOCOL=$(jq --raw-output ".deployment_key_protocol" $CONFIG_PATH)
REPOSITORY=$(jq --raw-output '.repository' $CONFIG_PATH)
AUTO_RESTART=$(jq --raw-output '.auto_restart' $CONFIG_PATH)
REPEAT_ACTIVE=$(jq --raw-output '.repeat.active' $CONFIG_PATH)
REPEAT_INTERVAL=$(jq --raw-output '.repeat.interval' $CONFIG_PATH)

# prepare the private key, if provided
if [ ! -z "$DEPLOYMENT_KEY" ]; then
    echo "[Info] setup deployment_key on id_${DEPLOYMENT_KEY_PROTOCOL}"

    mkdir -p ~/.ssh
    while read -r line; do
        echo "$line" >> "${HOME}/.ssh/id_${DEPLOYMENT_KEY_PROTOCOL}"
    done <<< "$DEPLOYMENT_KEY"

    chmod 600 "${HOME}/.ssh/id_${DEPLOYMENT_KEY_PROTOCOL}"
fi


# init config repositorie
if [ ! -d /config/.git ]; then
    echo "[Info] cleanup config folder and clone from repositorie"
    rm -rf /config/.[!.]* /config/* 2&> /dev/null

    if ! git clone "$REPOSITORY" /config 2&> /dev/null; then
        echo "[Error] can't clone $REPOSITORY into /config"
        exit 1
    fi
fi

# Main programm
cd /config
while true; do

    # get actual commit id
    echo "[Info] pull from $REPOSITORY"
    
    # perform pull
    OLD_COMMIT=$(git rev-parse HEAD)
    git pull 2&> /dev/null || true
    
    # get actual (new) commit id
    NEW_COMMIT=$(git rev-parse HEAD)

    # Enable autorestart of homeassistant
    if [ "$AUTO_RESTART" == "true" ]; then

        # Compare commit ids & check config
        if [ $NEW_COMMIT != $OLD_COMMIT ]; then
            echo "[Info] check Home-Assistant config"
            if api_ret="$(curl -s -X POST http://hassio/homeassistant/check)"; then
                result="$(echo "$api_ret" | jq --raw-output ".result")"

                # Config is valid
                if [ "$result" != "error" ]; then
                    echo "[Info] restart Home-Assistant"
                    curl -s -X POST http://hassio/homeassistant/restart 2&> /dev/null || true
                else
                    echo "[Error] invalid config!"
                fi
            fi
        fi
    fi

    # do we repeat?
    if [ -z "$REPEAT_ACTIVE" ]; then
        exit 0
    fi
    sleep "$REPEAT_INTERVAL"
done
