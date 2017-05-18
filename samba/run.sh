#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

WORKGROUP=$(jq --raw-output ".workgroup // empty" $CONFIG_PATH)
GUEST=$(jq --raw-output ".guest // empty" $CONFIG_PATH)
USERNAME=$(jq --raw-output ".username // empty" $CONFIG_PATH)
PASSWORD=$(jq --raw-output ".password // empty" $CONFIG_PATH)
MAP_CONFIG=$(jq --raw-output ".map_config // empty" $CONFIG_PATH)
MAP_ADDONS=$(jq --raw-output ".map_addons // empty" $CONFIG_PATH)
MAP_SSL=$(jq --raw-output ".map_ssl // empty" $CONFIG_PATH)
MAP_SHARE=$(jq --raw-output ".map_share // empty" $CONFIG_PATH)


function write_config() {
    echo "
[$1]
   browseable = yes
   writeable = yes
   path = /$1

   #guest ok = yes
   #guest only = yes
   #public = yes

   #valid users = $USERNAME
   #force user = root
   #force group = root
" >> /etc/smb.conf
}

sed -i "s/%%WORKGROUP%%/$WORKGROUP/g" /etc/smb.conf

##
# Write shares to config
if [ "$MAP_CONFIG" == "true" ]; then
    write_config "config"
fi
if [ "$MAP_ADDONS" == "true" ]; then
    write_config "addons"
fi
if [ "$MAP_SSL" == "true" ]; then
    write_config "ssl"
fi
if [ "$MAP_SHARE" == "true" ]; then
    write_config "share"
fi

##
# Set authentication options
if [ "$GUEST" == "true" ]; then
    sed -i "s/#guest ok/guest ok/g" /etc/smb.conf
    sed -i "s/#guest only/guest only/g" /etc/smb.conf
    sed -i "s/#guest account/guest account/g" /etc/smb.conf
    sed -i "s/#map to guest/map to guest/g" /etc/smb.conf
    sed -i "s/#public/public/g" /etc/smb.conf
else
    sed -i "s/#valid users/valid users/g" /etc/smb.conf
    sed -i "s/#force user/force user/g" /etc/smb.conf
    sed -i "s/#force group/force group/g" /etc/smb.conf

    addgroup -g 1000 "$USERNAME"
    adduser -D -H -G "$USERNAME" -s /bin/false -u 1000 "$USERNAME"
    echo -e "$PASSWORD\n$PASSWORD" | smbpasswd -a -s -c /etc/smb.conf "$USERNAME"
fi

exec smbd -F -S -s /etc/smb.conf < /dev/null
