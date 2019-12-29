#!/usr/bin/env bashio
set -e

KEYS_PATH=/data/host_keys

WAIT_PIDS=()

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

# Make Hass.io TOKEN available on the CLI
echo "export HASSIO_TOKEN=${HASSIO_TOKEN}" >> /etc/profile.d/hassio.sh

# Remove old HASSIO_TOKEN from bash profile (if exists)
if bashio::fs.file_exists /data/.bash_profile; then
  sed -i "/export HASSIO_TOKEN=.*/d" /data/.bash_profile
fi

# Persist .bash_profile by redirecting .bash_profile to /data
chmod 600 /data/.bash_profile
ln -s -f /data/.bash_profile /root/.bash_profile

# Sets up the users .ssh folder to be persistent
if ! bashio::fs.directory_exists /data/.ssh; then
    mkdir -p /data/.ssh \
        || bashio::exit.nok 'Failed to create a persistent .ssh folder'

    chmod 700 /data/.ssh \
        || bashio::exit.nok \
            'Failed setting permissions on persistent .ssh folder'
fi
ln -s /data/.ssh /root/.ssh

# Register stop
function stop_addon() {
    bashio::log.debug "Kill Processes..."
    kill -15 "${WAIT_PIDS[@]}"

    wait "${WAIT_PIDS[@]}"
    bashio::log.debug "Done."
}
trap "stop_addon" SIGTERM SIGHUP

# Start SSH server
bashio::log.info "Starting SSH daemon..."
/usr/sbin/sshd -D -e < /dev/null &
WAIT_PIDS+=($!)

# Start ttyd server
bashio::log.info "Starting Web Terminal..."
ttyd -p 8099 tmux -u new -A -s hassio bash -l &
WAIT_PIDS+=($!)

# Wait until all is done
bashio::log.info "SSH add-on is set up and running!"
wait "${WAIT_PIDS[@]}"