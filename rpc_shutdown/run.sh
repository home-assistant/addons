#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

COMPUTERS=$(jq --raw-output '.computers | length' $CONFIG_PATH)

# Read from STDIN aliases to send shutdown
while read -r alias; do

  # Find aliases -> computer
  for (( i=0; i < "$COMPUTERS"; i++ )); do
      ALIAS=$(jq --raw-output ".computers[$i].alias" $CONFIG_PATH)
      ADDRESS=$(jq --raw-output ".computers[$i].address" $CONFIG_PATH)
      CREDENTIALS=$(jq --raw-output ".computers[$i].credentials" $CONFIG_PATH)
      
  done

done
