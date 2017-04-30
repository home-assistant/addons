#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

WORKGROUP=$(jq --raw-output ".workgroup // empty" $CONFIG_PATH)
GUEST=$(jq --raw-output ".guest // empty" $CONFIG_PATH)
USERNAME=$(jq --raw-output ".username // empty" $CONFIG_PATH)
PASSWORD=$(jq --raw-output ".password // empty" $CONFIG_PATH)

sed -i "s/%%WORKGROUP%%/$WORKGROUP/g" /etc/smb.conf

if [ $GUEST == "true" ]; then
    echo "   guest ok = yes" >> /etc/smb.conf
    echo "   guest only = yes" >> /etc/smb.conf
    echo "   public = yes" >> /etc/smb.conf

    sed -i "s/#guest account/guest account/g" /etc/smb.conf
    sed -i "s/#map to guest/map to guest/g" /etc/smb.conf
else
    echo "   valid users = $USERNAME" >> /etc/smb.conf
    echo "   force user = root" >> /etc/smb.conf
    echo "   force group = root" >> /etc/smb.conf

    addgroup -g 1000 $USERNAME
    adduser -D -H -G $USERNAME -s /bin/false -u 1000 $USERNAME
    echo -e "$PASSWORD\n$PASSWORD" | smbpasswd -a -s -c /etc/smb.conf $USERNAME
fi

exec smbd -F -S -s /etc/smb.conf < /dev/null
