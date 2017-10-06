#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

COMPUTERS=$(jq --raw-output '.computers | length' $CONFIG_PATH)

# Read from STDIN aliases to send shutdown
while read -r input; do
    echo "[Info] Read alias: $input"

    # Find aliases -> computer
    for (( i=0; i < "$COMPUTERS"; i++ )); do
        ALIAS=$(jq --raw-output ".computers[$i].alias" $CONFIG_PATH)
        ADDRESS=$(jq --raw-output ".computers[$i].address" $CONFIG_PATH)
        CREDENTIALS=$(jq --raw-output ".computers[$i].credentials" $CONFIG_PATH)
      
        # Not the correct alias
        if [ "$ALIAS" != "$input" ]; then
            continue
        fi
      
        echo "[Info] Shutdown $input -> $ADDRESS"
        if ! msg="$(net rpc shutdown -I "$ADDRESS" -U "$CREDENTIALS")"; then
            echo "[Error] Shutdown fails!\n$msg"
        fi
    done
done
