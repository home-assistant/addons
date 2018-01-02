#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

WORKGROUP=$(jq --raw-output '.workgroup' $CONFIG_PATH)
NAME=$(jq --raw-output '.name' $CONFIG_PATH)
GUEST=$(jq --raw-output '.guest' $CONFIG_PATH)
USERNAME=$(jq --raw-output '.username // empty' $CONFIG_PATH)
PASSWORD=$(jq --raw-output '.password // empty' $CONFIG_PATH)
MAP_CONFIG=$(jq --raw-output '.map.config' $CONFIG_PATH)
MAP_ADDONS=$(jq --raw-output '.map.addons' $CONFIG_PATH)
MAP_SSL=$(jq --raw-output '.map.ssl' $CONFIG_PATH)
MAP_SHARE=$(jq --raw-output '.map.share' $CONFIG_PATH)
MAP_BACKUP=$(jq --raw-output '.map.backup' $CONFIG_PATH)
INTERFACE=$(jq --raw-output '.interface // empty' $CONFIG_PATH)

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
sed -i "s/%%NAME%%/$NAME/g" /etc/smb.conf
sed -i "s/%%INTERFACE%%/$INTERFACE/g" /etc/smb.conf

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
if [ "$MAP_BACKUP" == "true" ]; then
    write_config "backup"
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
    # shellcheck disable=SC1117
    echo -e "$PASSWORD\n$PASSWORD" | smbpasswd -a -s -c /etc/smb.conf "$USERNAME"
fi

nmbd -F -S -s /etc/smb.conf &
NMBD_PID=$!
smbd -F -S -s /etc/smb.conf &
SMBD_PID=$!

# Register stop
function stop_samba() {
    kill -15 "$NMBD_PID"
    kill -15 "$SMBD_PID"
    wait "$SMBD_PID" "$NMBD_PID"
}
trap "stop_samba" SIGTERM SIGHUP

wait "$SMBD_PID" "$NMBD_PID"
