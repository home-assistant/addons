#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

PYPI="$(jq --raw-output '.pypi | join(" ")' $CONFIG_PATH)"
APK="$(jq --raw-output '.apk | join(" ") // empty' $CONFIG_PATH)"

# Cleanup old deps
echo "[Info] Remove old deps"
rm -rf /config/deps/*

# Need custom apk for build?
if [ ! -z "$APK" ]; then
    echo "[Info] Install apks for build"
    if ! ERROR="$(apk add --no-cache "${APK[@]}")"; then
        echo "[Error] Can't install packages!"
        echo "$ERROR" && exit 1
    fi
fi

# Install pypi modules
echo "[Info] Install pypi modules into deps"
export PYTHONUSERBASE=/config/deps

# shellcheck disable=SC2086
if ! ERROR="$(pip3 install --user --no-cache-dir --prefix= --no-dependencies $PYPI)"; then
    echo "[Error] Can't install pypi packages!"
    echo "$ERROR" && exit 1
fi

echo "[Info] done"
