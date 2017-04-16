#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

WORKGROUP=$(jq --raw-output ".workgroup // empty" $CONFIG_PATH)
GUEST=$(jq --raw-output ".guest // empty" $CONFIG_PATH)
USERNAME=$(jq --raw-output ".username // empty" $CONFIG_PATH)
PASSWORD=$(jq --raw-output ".password // empty" $CONFIG_PATH)

sed -i "/workgroup =.*/workgroup = $WORKGROUP/" /etc/smb.conf

if [ GUEST == "true" ];
    sed -i "/group ok =.*/group ok = yes/" /etc/smb.conf
    sed -i "/public =.*/public = yes/" /etc/smb.conf
else
    sed -i "/group ok =.*/group ok = no/" /etc/smb.conf
    sed -i "/public =.*/public = no/" /etc/smb.conf
fi

smbd -F -S -s /etc/smb.conf
