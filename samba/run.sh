#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

WORKGROUP=$(jq --raw-output '.workgroup' $CONFIG_PATH)
INTERFACE=$(jq --raw-output '.interface // empty' $CONFIG_PATH)
ALLOW_HOSTS=$(jq --raw-output '.allow_hosts | join(" ")' $CONFIG_PATH)
USERNAME=$(jq --raw-output '.username // empty' $CONFIG_PATH)
PASSWORD=$(jq --raw-output '.password // empty' $CONFIG_PATH)

WAIT_PIDS=()
NAME=

# Check Login data
if [ -z "${USERNAME}" ] || [ -z "${PASSWORD}" ]; then
    echo "[ERROR] No valid login data inside options!"
    exit 1
fi

# Read hostname from API
if ! NAME="$(curl -s -f -H "X-Hassio-Key: ${HASSIO_TOKEN}" http://hassio/info | jq --raw-output '.data.hostname')"; then
    echo "[WARN] Can't read hostname, use default!"
    NAME="hassio"
else
    echo "[INFO] Read hostname: ${NAME}"
fi

# Setup config
sed -i "s|%%WORKGROUP%%|$WORKGROUP|g" /etc/smb.conf
sed -i "s|%%NAME%%|$NAME|g" /etc/smb.conf
sed -i "s|%%INTERFACE%%|$INTERFACE|g" /etc/smb.conf
sed -i "s|%%ALLOW_HOSTS%%|$ALLOW_HOSTS|g" /etc/smb.conf
sed -i "s|%%USERNAME%%|$USERNAME|g" /etc/smb.conf

# Init users
addgroup "${USERNAME}"
adduser -D -H -G "${USERNAME}" -s /bin/false "${USERNAME}"
# shellcheck disable=SC1117
echo -e "${PASSWORD}\n${PASSWORD}" | smbpasswd -a -s -c /etc/smb.conf "${USERNAME}"

# Start samba
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
