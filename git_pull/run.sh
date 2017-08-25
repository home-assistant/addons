#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

REPOSITORY=$(jq --raw-output '.repository' $CONFIG_PATH)
AUTO_RESTART=$(jq --raw-output '.auto_restart' $CONFIG_PATH)
REPEAT_ACTIVE=$(jq --raw-output '.repeat.active' $CONFIG_PATH)
REPEAT_INTERVAL=$(jq --raw-output '.repeat.interval' $CONFIG_PATH)

# init config repositorie
if [ ! -d /config/.git ]; then
    echo "[Info] cleanup config folder and clone from repositorie"
    rm -rf /config/.[!.]* /config/* 2&> /dev/null

    if ! git clone "$REPOSITORY" /config 2&> /dev/null; then
        echo "[Error] can't clone $REPOSITORY into /config"
        exit 1
    fi
fi

# Run duckdns
cd /config
while true; do

    echo "[Info] pull from $REPOSITORY"
    git pull 2&> /dev/null || true

    # Enable autorestart of homeassistant
    if [ "$AUTO_RESTART" == "true" ]; then
        changed_files="$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD)"

        # Files have changed & check config
        if [ ! -z "$changed_files" ]; then
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
