#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
KEYS_PATH=/data/host_keys

AUTHORIZED_KEYS=$(jq --raw-output ".authorized_keys[]" $CONFIG_PATH)

# Init defaults config
sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config
sed -i s/#PasswordAuthentication.*/PasswordAuthentication\ no/ /etc/ssh/sshd_config
sed -i s/#LogLevel.*/LogLevel\ DEBUG/ /etc/ssh/sshd_config

# Generate authorized_keys file
mkdir -p ~/.ssh
while read -r line; do
    echo "$line" >> ~/.ssh/authorized_keys
done <<< "$AUTHORIZED_KEYS"
chmod 600 ~/.ssh/authorized_keys

# Generate host keys
if [ ! -d "$KEYS_PATH" ]; then
    mkdir -p "$KEYS_PATH"
    ssh-keygen -A
    cp -fp /etc/ssh/ssh_host* "$KEYS_PATH/"
else
    cp -fp "$KEYS_PATH"/* /etc/ssh/
fi

# start server
exec /usr/sbin/sshd -D -e < /dev/null
