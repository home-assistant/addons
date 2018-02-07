#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
KEYS_PATH=/data/host_keys

AUTHORIZED_KEYS=$(jq --raw-output ".authorized_keys[]" $CONFIG_PATH)
PASSWORD=$(jq --raw-output ".password" $CONFIG_PATH)

# Init defaults config
sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config
sed -i s/#LogLevel.*/LogLevel\ DEBUG/ /etc/ssh/sshd_config

if [ ! -z "$AUTHORIZED_KEYS" ]; then
    echo "[INFO] Setup authorized_keys"

    mkdir -p ~/.ssh
    while read -r line; do
        echo "$line" >> ~/.ssh/authorized_keys
    done <<< "$AUTHORIZED_KEYS"

    chmod 600 ~/.ssh/authorized_keys
    sed -i s/#PasswordAuthentication.*/PasswordAuthentication\ no/ /etc/ssh/sshd_config
elif [ ! -z "$PASSWORD" ]; then
    echo "[INFO] Setup password login"

    echo "root:$PASSWORD" | chpasswd 2&> /dev/null
    sed -i s/#PasswordAuthentication.*/PasswordAuthentication\ yes/ /etc/ssh/sshd_config
    sed -i s/#PermitEmptyPasswords.*/PermitEmptyPasswords\ no/ /etc/ssh/sshd_config
else
    echo "[Error] You need setup a login!"
    exit 1
fi

# Generate host keys
if [ ! -d "$KEYS_PATH" ]; then
    echo "[INFO] Create host keys"

    mkdir -p "$KEYS_PATH"
    ssh-keygen -A
    cp -fp /etc/ssh/ssh_host* "$KEYS_PATH/"
else
    echo "[INFO] Restore host keys"
    cp -fp "$KEYS_PATH"/* /etc/ssh/
fi

# Persist shell history by redirecting .ash_history to /data
touch /data/.bash_history
chmod 600 /data/.bash_history
ln -s -f /data/.bash_history /root/.bash_history

# Store token for hass.io API
echo "export HASSIO_TOKEN=$HASSIO_TOKEN" >> /root/.bash_profile

# start server
exec /usr/sbin/sshd -D -e < /dev/null
