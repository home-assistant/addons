#!/usr/bin/env bashio
set -e

WORKGROUP=$(bashio::config 'workgroup')
INTERFACE=$(bashio::config 'interface')
ALLOW_HOSTS=$(bashio::config 'allow_hosts')
USERNAME=$(bashio::config 'username')
PASSWORD=$(bashio::config 'password')

WAIT_PIDS=()
NAME=

# Check Login data
if [ -z "${USERNAME}" ] || [ -z "${PASSWORD}" ]; then
    bashio::log.error "No valid login data inside options!"
    exit 1
fi

# Read hostname from API
if ! NAME="$(curl -s -f -H "X-Hassio-Key: ${HASSIO_TOKEN}" http://hassio/info | jq --raw-output '.data.hostname')"; then
    bashio::log.warn "Can't read hostname, use default!"
    NAME="hassio"
else
    bashio::log.info "Read hostname: ${NAME}"
fi

# Workaround to create usable IPRanges from ALLOW_HOSTS variable
IPRANGES=
for item in $ALLOW_HOSTS; do
         IPRANGES="$IPRANGES ${item}"
     done

# Setup config
sed -i "s|%%WORKGROUP%%|${WORKGROUP}|g" /etc/smb.conf
sed -i "s|%%NAME%%|${NAME}|g" /etc/smb.conf
sed -i "s|%%INTERFACE%%|${INTERFACE}|g" /etc/smb.conf
sed -i "s|%%USERNAME%%|${USERNAME}|g" /etc/smb.conf
sed -i "s#%%ALLOW_HOSTS%%#${IPRANGES}#g" /etc/smb.conf

cat /etc/smb.conf
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
    bashio::log.info "Kill Processes..."
    kill -15 "${WAIT_PIDS[@]}"
    wait "${WAIT_PIDS[@]}"
    bashio::log.info "Done."
}
trap "stop_samba" SIGTERM SIGHUP

# Wait until all is done
wait "${WAIT_PIDS[@]}"
