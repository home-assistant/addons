#!/usr/bin/env bashio
set -e

KEYS_PATH=/data/host_keys

bashio::log.info "Initializing add-on for use..."
if bashio::config.has_value 'authorized_keys'; then
    bashio::log.info "Setup authorized_keys"

    mkdir -p ~/.ssh
    while read -r line; do
        echo "$line" >> ~/.ssh/authorized_keys
    done <<< "$(bashio::config 'authorized_keys')"

    chmod 600 ~/.ssh/authorized_keys
    sed -i s/#PasswordAuthentication.*/PasswordAuthentication\ no/ /etc/ssh/sshd_config

    # Unlock account
    PASSWORD="$(pwgen -s 64 1)"
    echo "root:${PASSWORD}" | chpasswd 2&> /dev/null
elif bashio::config.has_value 'password'; then
    bashio::log.info "Setup password login"

    PASSWORD=$(bashio::config 'password')
    echo "root:${PASSWORD}" | chpasswd 2&> /dev/null

    sed -i s/#PasswordAuthentication.*/PasswordAuthentication\ yes/ /etc/ssh/sshd_config
    sed -i s/#PermitEmptyPasswords.*/PermitEmptyPasswords\ no/ /etc/ssh/sshd_config
else
    bashio::exit.nok "You need to setup a login!"
fi

# Generate host keys
if ! bashio::fs.directory_exists "${KEYS_PATH}"; then
    bashio::log.info "Generating host keys..."

    mkdir -p "${KEYS_PATH}"
    ssh-keygen -A || bashio::exit.nok "Failed to create host keys!"
    cp -fp /etc/ssh/ssh_host* "${KEYS_PATH}/"
else
    bashio::log.info "Restoring host keys..."
    cp -fp "${KEYS_PATH}"/* /etc/ssh/
fi

# Persist shell history by redirecting .bash_history to /data
touch /data/.bash_history
chmod 600 /data/.bash_history
ln -s -f /data/.bash_history /root/.bash_history

# Store token for Hass.io API
while read -r line ; do
  echo "$line" >> /root/.bash_profile
done <<< "$(bashio::config 'bash_profile')"

echo "export HASSIO_TOKEN=${HASSIO_TOKEN}" >> /root/.bash_profile

# Start server
bashio::log.info "Starting SSH daemon..."
exec /usr/sbin/sshd -D -e < /dev/null
