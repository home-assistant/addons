#!/usr/bin/with-contenv bashio
# ==============================================================================
# SSH setup & user
# ==============================================================================
if bashio::config.has_value 'authorized_keys'; then
    bashio::log.info "Setup authorized_keys"

    mkdir -p /data/.ssh
    chmod 700 /data/.ssh
    rm -f /data/.ssh/authorized_keys
    while read -r line; do
        echo "$line" >> /data/.ssh/authorized_keys
    done <<< "$(bashio::config 'authorized_keys')"

    chmod 600 /data/.ssh/authorized_keys
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
elif bashio::var.has_value "$(bashio::addon.port 22)"; then
    bashio::exit.nok "You need to setup a login!"
fi

# Allow TCP forwarding
if bashio::config.true 'server.tcp_forwarding'; then
    sed -i "s/AllowTcpForwarding.*/AllowTcpForwarding\\ yes/" /etc/ssh/sshd_config
fi
