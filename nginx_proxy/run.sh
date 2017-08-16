#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
DHPARAMS_PATH=/data/dhparams.pem

DOMAIN=$(jq --raw-output ".domain" $CONFIG_PATH)
KEYFILE=$(jq --raw-output ".keyfile" $CONFIG_PATH)
CERTFILE=$(jq --raw-output ".certfile" $CONFIG_PATH)

USER_COUNT=$(jq --raw-output ".basic_auth_users | length" $CONFIG_PATH)

# Generate dhparams
if [ ! -f "$DHPARAMS_PATH" ]; then
    echo "[INFO] Generate dhparams..."
    openssl dhparam -dsaparam -out "$DHPARAMS_PATH" 4096 > /dev/null
fi

# Prepare config file
sed -i "s/%%FULLCHAIN%%/$CERTFILE/g" /etc/nginx.conf
sed -i "s/%%PRIVKEY%%/$KEYFILE/g" /etc/nginx.conf
sed -i "s/%%DOMAIN%%/$DOMAIN/g" /etc/nginx.conf

if [ "$USER_COUNT" == "0" ]; then
    sed -i "s/auth_basic \"Authorized users only\";/# auth_basic \"Authorized users only\";/g" /etc/nginx.conf
    sed -i "s/auth_basic_user_file \/data\/\.htpasswd;/# auth_basic_user_file \/data\/\.htpasswd;/g" /etc/nginx.conf
else
    sed -i "s/# auth_basic \"Authorized users only\";/auth_basic \"Authorized users only\";/g" /etc/nginx.conf
    sed -i "s/# auth_basic_user_file \/data\/\.htpasswd;/auth_basic_user_file \/data\/\.htpasswd;/g" /etc/nginx.conf
fi

for (( i=0; i < "$USER_COUNT"; i++ )); do
    USERNAME=$(jq --raw-output ".basic_auth_users[$i].username" $CONFIG_PATH)
    PASSWORD=$(jq --raw-output ".basic_auth_users[$i].password" $CONFIG_PATH)
    echo "[INFO] Adding user $USERNAME"
    if [ "$i" == "0" ]; then
        htpasswd -cb /data/.htpasswd $USERNAME $PASSWORD
    else
        htpasswd -b /data/.htpasswd $USERNAME $PASSWORD
    fi
done

# start server
echo "[INFO] Run nginx"
exec nginx -c /etc/nginx.conf < /dev/null
