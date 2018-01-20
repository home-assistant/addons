#!/bin/bash

#### config ####

CONFIG_PATH=/data/options.json
INSTALL_PATH=/bin/hue-mqtt-bridge
################


## generate config file ##
echo "[Info] starting shell script"
mkdir "$INSTALL_PATH"
git clone https://github.com/dale3h/hue-mqtt-bridge.git "$INSTALL_PATH"
cd "$INSTALL_PATH"
npm i 

## copy config file
cp "$CONFIG_PATH" "$INSTALL_PATH/config.json"

## run module ##
./bin/hue-mqtt-bridge
