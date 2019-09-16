#!/bin/bash
set -e

CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir
CONFIG_PATH=/data/options.json

EMAIL=$(jq --raw-output ".email" $CONFIG_PATH)
DOMAINS=$(jq --raw-output ".domains[]" $CONFIG_PATH)
KEYFILE=$(jq --raw-output ".keyfile" $CONFIG_PATH)
CERTFILE=$(jq --raw-output ".certfile" $CONFIG_PATH)
CHALLENGE=$(jq --raw-output ".challenge" $CONFIG_PATH)
DNSPROVIDER=$(jq --raw-output ".dnsprovider" $CONFIG_PATH)
dns_cloudflare_email=$(jq --raw-output ".dns_cloudflare_email" $CONFIG_PATH)
dns_cloudflare_api_key=$(jq --raw-output ".dns_cloudflare_api_key" $CONFIG_PATH)
dns_cloudxns_api_key=$(jq --raw-output ".dns_cloudxns_api_key" $CONFIG_PATH)
dns_cloudxns_secret_key=$(jq --raw-output ".dns_cloudxns_secret_key" $CONFIG_PATH)
dns_digitalocean_token=$(jq --raw-output ".dns_digitalocean_token" $CONFIG_PATH)
dns_dnsimple_token=$(jq --raw-output ".dns_dnsimple_token" $CONFIG_PATH)
dns_dnsmadeeasy_api_key=$(jq --raw-output ".dns_dnsmadeeasy_api_key" $CONFIG_PATH)
dns_dnsmadeeasy_secret_key=$(jq --raw-output ".dns_dnsmadeeasy_secret_key" $CONFIG_PATH)
dns_gehirn_api_token=$(jq --raw-output ".dns_gehirn_api_token" $CONFIG_PATH)
dns_gehirn_api_secret=$(jq --raw-output ".dns_gehirn_api_secret" $CONFIG_PATH)
dns_linode_key=$(jq --raw-output ".dns_linode_key" $CONFIG_PATH)
dns_linode_version=$(jq --raw-output ".dns_linode_version" $CONFIG_PATH)
dns_luadns_email=$(jq --raw-output ".dns_luadns_email" $CONFIG_PATH)
dns_luadns_token=$(jq --raw-output ".dns_luadns_token" $CONFIG_PATH)
dns_nsone_api_key=$(jq --raw-output ".dns_nsone_api_key" $CONFIG_PATH)
dns_ovh_endpoint=$(jq --raw-output ".dns_ovh_endpoint" $CONFIG_PATH)
dns_ovh_application_key=$(jq --raw-output ".dns_ovh_application_key" $CONFIG_PATH)
dns_ovh_application_secret=$(jq --raw-output ".dns_ovh_application_secret" $CONFIG_PATH)
dns_ovh_consumer_key=$(jq --raw-output ".dns_ovh_consumer_key" $CONFIG_PATH)
dns_rfc2136_server=$(jq --raw-output ".dns_rfc2136_server" $CONFIG_PATH)
dns_rfc2136_port=$(jq --raw-output ".dns_rfc2136_port" $CONFIG_PATH)
dns_rfc2136_name=$(jq --raw-output ".dns_rfc2136_name" $CONFIG_PATH)
dns_rfc2136_secret=$(jq --raw-output ".dns_rfc2136_secret" $CONFIG_PATH)
dns_rfc2136_algorithm=$(jq --raw-output ".dns_rfc2136_algorithm" $CONFIG_PATH)
aws_access_key_id=$(jq --raw-output ".aws_access_key_id" $CONFIG_PATH)
aws_secret_access_key=$(jq --raw-output ".aws_secret_access_key" $CONFIG_PATH)
dns_sakuracloud_api_token=$(jq --raw-output ".dns_sakuracloud_api_token" $CONFIG_PATH)
dns_sakuracloud_api_secret=$(jq --raw-output ".dns_sakuracloud_api_secret" $CONFIG_PATH)

mkdir -p "$WORK_DIR"
mkdir -p "$CERT_DIR"
mkdir -p "/ssl"
chmod +x /run.sh
touch /data/dnsapikey

echo "dns_cloudflare_email = " $(jq --raw-output ".dns_cloudflare_email" /data/options.json) >> /data/dnsapikey
echo "dns_cloudflare_api_key = " $(jq --raw-output ".dns_cloudflare_api_key" /data/options.json) >> /data/dnsapikey
echo "dns_cloudxns_api_key = " $(jq --raw-output ".dns_cloudxns_api_key" /data/options.json) >> /data/dnsapikey
echo "dns_cloudxns_secret_key = " $(jq --raw-output ".dns_cloudxns_secret_key" /data/options.json) >> /data/dnsapikey
echo "dns_digitalocean_token = " $(jq --raw-output ".dns_digitalocean_token" /data/options.json) >> /data/dnsapikey
echo "dns_dnsimple_token = " $(jq --raw-output ".dns_dnsimple_token" /data/options.json) >> /data/dnsapikey
echo "dns_dnsmadeeasy_api_key = " $(jq --raw-output ".dns_dnsmadeeasy_api_key" /data/options.json) >> /data/dnsapikey
echo "dns_dnsmadeeasy_secret_key = " $(jq --raw-output ".dns_cloudflare_email" /data/options.json) >> /data/dnsapikey
echo "dns_gehirn_api_token = " $(jq --raw-output ".dns_gehirn_api_token" /data/options.json) >> /data/dnsapikey
echo "dns_gehirn_api_secret = " $(jq --raw-output ".dns_gehirn_api_secret" /data/options.json) >> /data/dnsapikey
echo "dns_linode_key = " $(jq --raw-output ".dns_linode_key" /data/options.json) >> /data/dnsapikey
echo "dns_linode_version = " $(jq --raw-output ".dns_linode_version" /data/options.json) >> /data/dnsapikey
echo "dns_luadns_email = " $(jq --raw-output ".dns_luadns_email" /data/options.json) >> /data/dnsapikey
echo "dns_luadns_token = " $(jq --raw-output ".dns_luadns_token" /data/options.json) >> /data/dnsapikey
echo "dns_nsone_api_key = " $(jq --raw-output ".dns_nsone_api_key" /data/options.json) >> /data/dnsapikey
echo "dns_ovh_endpoint = " $(jq --raw-output ".dns_ovh_endpoint" /data/options.json) >> /data/dnsapikey
echo "dns_ovh_application_key = " $(jq --raw-output ".dns_ovh_application_key" /data/options.json) >> /data/dnsapikey
echo "dns_ovh_application_secret = " $(jq --raw-output ".dns_ovh_application_secret" /data/options.json) >> /data/dnsapikey
echo "dns_ovh_consumer_key = " $(jq --raw-output ".dns_ovh_consumer_key" /data/options.json) >> /data/dnsapikey
echo "dns_rfc2136_server = " $(jq --raw-output ".dns_rfc2136_server" /data/options.json) >> /data/dnsapikey
echo "dns_rfc2136_port = " $(jq --raw-output ".dns_rfc2136_port" /data/options.json) >> /data/dnsapikey
echo "dns_rfc2136_name = " $(jq --raw-output ".dns_rfc2136_name" /data/options.json) >> /data/dnsapikey
echo "dns_rfc2136_secret = " $(jq --raw-output ".dns_rfc2136_secret" /data/options.json) >> /data/dnsapikey
echo "dns_rfc2136_algorithm = " $(jq --raw-output ".dns_rfc2136_algorithm" /data/options.json) >> /data/dnsapikey
echo "aws_access_key_id = " $(jq --raw-output ".aws_access_key_id" /data/options.json) >> /data/dnsapikey
echo "aws_secret_access_key = " $(jq --raw-output ".aws_secret_access_key" /data/options.json) >> /data/dnsapikey
echo "dns_sakuracloud_api_token = " $(jq --raw-output ".dns_sakuracloud_api_token" /data/options.json) >> /data/dnsapikey
echo "dns_sakuracloud_api_secret = " $(jq --raw-output ".dns_sakuracloud_api_secret" /data/options.json) >> /data/dnsapikey
chmod 600 /data/dnsapikey

# Generate new certs
if [ ! -d "$CERT_DIR/live" ]; then
    DOMAIN_ARR=()
    for line in $DOMAINS; do
        DOMAIN_ARR+=(-d "$line")
    done

    echo "$DOMAINS" > /data/domains.gen
    if [ $CHALLENGE == "dns" ]; then
        certbot certonly --non-interactive --config-dir "$CERT_DIR" --work-dir "$WORK_DIR" --"$DNSPROVIDER" --"$DNSPROVIDER"-credentials "/data/dnsapikey" --email "$EMAIL" --agree-tos --config-dir "$CERT_DIR" --work-dir "$WORK_DIR" --preferred-challenges "$CHALLENGE" "${DOMAIN_ARR[@]}"
    else
        certbot certonly --non-interactive --standalone --email "$EMAIL" --agree-tos --config-dir "$CERT_DIR" --work-dir "$WORK_DIR" --preferred-challenges "$CHALLENGE" "${DOMAIN_ARR[@]}"
    fi
else
    certbot renew --non-interactive --config-dir "$CERT_DIR" --work-dir "$WORK_DIR" --preferred-challenges "$CHALLENGE"
fi

# copy certs to store
cp "$CERT_DIR"/live/*/privkey.pem "/ssl/$KEYFILE"
cp "$CERT_DIR"/live/*/fullchain.pem "/ssl/$CERTFILE"