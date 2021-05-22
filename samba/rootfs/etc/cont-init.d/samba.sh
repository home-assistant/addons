#!/usr/bin/with-contenv bashio
# ==============================================================================
# Prepare the Samba service for running
# ==============================================================================
declare password
declare username
export HOSTNAME

# Check Login data
if ! bashio::config.has_value 'username' || ! bashio::config.has_value 'password'; then
    bashio::exit.nok "Setting a username and password is required!"
fi

# Read hostname from API or setting default "hassio"
HOSTNAME=$(bashio::info.hostname)
if bashio::var.is_empty "${HOSTNAME}"; then
    bashio::log.warning "Can't read hostname, using default."
    HOSTNAME="hassio"
fi
bashio::log.info "Hostname: ${HOSTNAME}"

# Generate Samba configuration.
tempio \
  -conf /data/options.json \
  -template /usr/share/tempio/smb.gtpl \
  -out /etc/samba/smb.conf

# Init user
username=$(bashio::config 'username')
password=$(bashio::config 'password')
addgroup "${username}"
adduser -D -H -G "${username}" -s /bin/false "${username}"
# shellcheck disable=SC1117
echo -e "${password}\n${password}" \
    | smbpasswd -a -s -c "/etc/samba/smb.conf" "${username}"
