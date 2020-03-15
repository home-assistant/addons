#!/usr/bin/env bashio

# shellcheck disable=SC1091
source "/opt/letsencrypt/lib/letsencrypt.sh"

CHALLENGE=$(bashio::config 'challenge')

CERT_DIR=$(letsencrypt::cert_dir)
WORK_DIR=$(letsencrypt::work_dir)
RENEWAL_OPTIONS=$(letsencrypt::renewal_options)
SERVER_OPTIONS=$(letsencrypt::server_options)

certbot renew --non-interactive --config-dir "$CERT_DIR" \
    --work-dir "$WORK_DIR" --preferred-challenges "$CHALLENGE" \
    --deploy-hook "/deploy.sh" --server "${SERVER_OPTIONS}" "$RENEWAL_OPTIONS"