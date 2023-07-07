#!/usr/bin/with-contenv bashio
# ==============================================================================
# SSH setup & user
# ==============================================================================

# Sets up the users .ssh folder to be persistent
if ! bashio::fs.directory_exists /data/.ssh; then
    mkdir -p /data/.ssh \
        || bashio::exit.nok 'Failed to create a persistent .ssh folder'

fi
chmod 700 /data/.ssh \
    || bashio::exit.nok \
        'Failed setting permissions on persistent .ssh folder'

# Make Home Assistant TOKEN available for non-interactive SSH commands
bashio::var.json \
    supervisor_token "${SUPERVISOR_TOKEN}" \
    | tempio \
        -template /usr/share/tempio/ssh.environment \
        -out /data/.ssh/environment

if bashio::config.has_value 'authorized_keys'; then
    bashio::log.info "Setup authorized_keys"

    rm -f /data/.ssh/authorized_keys
    while read -r line; do
        echo "$line" >> /data/.ssh/authorized_keys
    done <<< "$(bashio::config 'authorized_keys')"

    chmod 600 /data/.ssh/authorized_keys

    # Unlock account
    PASSWORD="$(pwgen -s 64 1)"
    echo "root:${PASSWORD}" | chpasswd 2&> /dev/null
elif bashio::config.has_value 'password'; then
    bashio::log.info "Setup password login"

    PASSWORD=$(bashio::config 'password')
    echo "root:${PASSWORD}" | chpasswd 2&> /dev/null
elif bashio::var.has_value "$(bashio::addon.port 22)"; then
    bashio::exit.nok "You need to setup a login!"
fi

if bashio::config.has_value 'server.trusted_user_ca_keys'; then
    bashio::config 'server.trusted_user_ca_keys' > /etc/ssh/ssh_ca.pub
fi

# Generate config
mkdir -p /etc/ssh
tempio \
    -conf /data/options.json \
    -template /usr/share/tempio/sshd_config \
    -out /etc/ssh/sshd_config

