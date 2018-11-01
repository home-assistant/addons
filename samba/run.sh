#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

WORKGROUP=$(jq --raw-output '.workgroup' $CONFIG_PATH)
INTERFACE=$(jq --raw-output '.interface // empty' $CONFIG_PATH)
ALLOW_HOSTS=$(jq --raw-output '.allow_hosts | join(" ")' $CONFIG_PATH)
NAME=

# Read hostname from API
if ! NAME="$(curl -q -f -H "X-Hassio-Key: ${HASSIO_TOKEN}" http://hassio/info | jq --raw-output '.hostname')"; then
    echo "[WARN] Can't read hostname, use default!"
    NAME="hassio"
fi

sed -i "s|%%WORKGROUP%%|$WORKGROUP|g" /etc/smb.conf
sed -i "s|%%NAME%%|$NAME|g" /etc/smb.conf
sed -i "s|%%INTERFACE%%|$INTERFACE|g" /etc/smb.conf
sed -i "s|%%ALLOW_HOSTS%%|$ALLOW_HOSTS|g" /etc/smb.conf

# Run usermanager
socat -t 5 TCP-LISTEN:9124,fork,reuseaddr EXEC:/bin/userdb.sh &
NMBD_PID=$!

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
