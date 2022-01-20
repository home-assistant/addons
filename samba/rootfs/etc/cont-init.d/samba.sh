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
if bashio::config.exists 'interfaces'; then
    bashio::log.info "Interfaces: $(printf '%s ' $(bashio::config 'interfaces'))"
    tempio \
      -conf /data/options.json \
      -template /usr/share/tempio/smb.gtpl \
      -out /etc/samba/smb.conf
else
    default_interface=$(bashio::network.name)
    bashio::log.info "Interfaces: ${default_interface}"
    jq ".interfaces = [\"${default_interface}\"]" /data/options.json \
        | tempio \
          -template /usr/share/tempio/smb.gtpl \
          -out /etc/samba/smb.conf
fi

# Init user
username=$(bashio::config 'username')
password=$(bashio::config 'password')
addgroup "${username}"
adduser -D -H -G "${username}" -s /bin/false "${username}"
# shellcheck disable=SC1117
echo -e "${password}\n${password}" \
    | smbpasswd -a -s -c "/etc/samba/smb.conf" "${username}"
