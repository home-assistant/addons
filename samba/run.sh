#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

WORKGROUP=$(jq --raw-output '.workgroup' $CONFIG_PATH)
INTERFACE=$(jq --raw-output '.interface // empty' $CONFIG_PATH)
ALLOW_HOSTS=$(jq --raw-output '.allow_hosts | join(" ")' $CONFIG_PATH)
KEYFILE=$(jq --raw-output ".keyfile" $CONFIG_PATH)
CERTFILE=$(jq --raw-output ".certfile" $CONFIG_PATH)
SSL=$(jq --raw-output ".ssl // false" $CONFIG_PATH)

WAIT_PIDS=()
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

# Init users
for username in $(pdbedit -L -s /etc/smb.conf | grep ':' | cut -d ':' -f0); do
    addgroup "${username}" > /dev/null
    adduser -D -H -G "${username}" -s /bin/false "${username}" > /dev/null
    echo -e "${password}\n${password}" | smbpasswd -a -s -c /etc/smb.conf "${username}" > /dev/null 
done

# Run usermanager
if [ "${SSL}" == "true" ]
    socat OPENSSL-LISTEN:9124,fork,reuseaddr,cafile="${CERTFILE}",key="${KEYFILE}" SYSTEM:/bin/userdb.sh &
else
    socat TCP-LISTEN:9124,fork,reuseaddr SYSTEM:/bin/userdb.sh &
fi
WAIT_PIDS+=($!)

nmbd -F -S -s /etc/smb.conf &
WAIT_PIDS+=($!)

smbd -F -S -s /etc/smb.conf &
WAIT_PIDS+=($!)

# Register stop
function stop_samba() {
    echo "Kill Processes..."
    kill -15 "${WAIT_PIDS[@]}"
    wait "${WAIT_PIDS[@]}"
    echo "Done."
}
trap "stop_samba" SIGTERM SIGHUP

# Wait until all is done
wait "${WAIT_PIDS[@]}"
