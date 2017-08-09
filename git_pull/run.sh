#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

REPOSITORIE=$(jq --raw-output '.repositorie' $CONFIG_PATH)
AUTO_RESTART=$(jq --raw-output '.auto_restart' $CONFIG_PATH)
REPEAT_ACTIVE=$(jq --raw-output '.repeat.active' $CONFIG_PATH)
REPEAT_INTERVAL=$(jq --raw-output '.repeat.interval' $CONFIG_PATH)

# init config repositorie
if [ ! -d /config/.git ]; then
    echo "[Info] cleanup config folder and clone from repositorie"
    rm -rf /config/.[!.]* /config/* 2&> /dev/null

    if ! git clone "$REPOSITORIE" /config 2&> /dev/null; then
        echo "[Error] can't clone $REPOSITORIE into /config"
        exit 1
    fi
fi

# Run duckdns
cd /config
while true; do

    echo "[Info] pull from $REPOSITORIE"
    git pull 2&> /dev/null || true

    if [ "$AUTO_RESTART" == "true" ]; then
        changed_files="$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD)"

        if [ ! -z "$changed_files" ]; then
            echo "[Info] files changed, restart Home-Assistant"
            curl -s http://hassio/homeassistant/restart 2&> /dev/null || true
        fi
    fi

    # do we repeat?
    if [ -z "$REPEAT_ACTIVE" ]; then
        exit 0
    fi
    sleep "$REPEAT_INTERVAL"
done
