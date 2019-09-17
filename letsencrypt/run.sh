#!/usr/bin/env bashio

USERNAME=$(bashio::config 'username')
EMAIL=$(bashio::config 'email')
DOMAINS=$(bashio::config 'domains')
KEYFILE=$(bashio::config 'keyfile')
CERTFILE=$(bashio::config 'certfile')
CHALLENGE=$(bashio::config 'challenge')
DNSPROVIDER=$(bashio::config 'dnsprovider')

CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir

mkdir -p "$WORK_DIR"
mkdir -p "$CERT_DIR"
mkdir -p "/ssl"
chmod +x /run.sh
touch /data/dnsapikey

echo "dns_cloudflare_email = " "$(bashio::config 'dns_cloudflare_email')" >> /data/dnsapikey
echo "dns_cloudflare_api_key = " "$(bashio::config 'dns_cloudflare_api_key')" >> /data/dnsapikey
echo "dns_cloudxns_api_key = " "$(bashio::config 'dns_cloudxns_api_key')" >> /data/dnsapikey
echo "dns_cloudxns_secret_key = " "$(bashio::config 'dns_cloudxns_secret_key')" >> /data/dnsapikey
echo "dns_digitalocean_token = " "$(bashio::config 'dns_digitalocean_token')" >> /data/dnsapikey
echo "dns_dnsimple_token = " "$(bashio::config 'dns_dnsimple_token')" >> /data/dnsapikey
echo "dns_dnsmadeeasy_api_key = " "$(bashio::config 'dns_dnsmadeeasy_api_key')" >> /data/dnsapikey
echo "dns_dnsmadeeasy_secret_key = " "$(bashio::config 'dns_dnsmadeeasy_secret_key')" >> /data/dnsapikey
echo "dns_gehirn_api_token = " "$(bashio::config 'dns_gehirn_api_token')" >> /data/dnsapikey
echo "dns_gehirn_api_secret = " "$(bashio::config 'dns_gehirn_api_secret')" >> /data/dnsapikey
echo "dns_linode_key = " "$(bashio::config 'dns_linode_key')" >> /data/dnsapikey
echo "dns_linode_version = " "$(bashio::config 'dns_linode_version')" >> /data/dnsapikey
echo "dns_luadns_email = " "$(bashio::config 'dns_luadns_email')" >> /data/dnsapikey
echo "dns_luadns_token = " "$(bashio::config 'dns_luadns_token')" >> /data/dnsapikey
echo "dns_nsone_api_key = " "$(bashio::config 'dns_nsone_api_key')" >> /data/dnsapikey
echo "dns_ovh_endpoint = " "$(bashio::config 'dns_ovh_endpoint')" >> /data/dnsapikey
echo "dns_ovh_application_key = " "$(bashio::config 'dns_ovh_application_key')" >> /data/dnsapikey
echo "dns_ovh_application_secret = " "$(bashio::config 'dns_ovh_application_secret')" >> /data/dnsapikey
echo "dns_ovh_consumer_key = " "$(bashio::config 'dns_ovh_consumer_key')" >> /data/dnsapikey
echo "dns_rfc2136_server = " "$(bashio::config 'dns_rfc2136_server')" >> /data/dnsapikey
echo "dns_rfc2136_port = " "$(bashio::config 'dns_rfc2136_port')" >> /data/dnsapikey
echo "dns_rfc2136_name = " "$(bashio::config 'dns_rfc2136_name')" >> /data/dnsapikey
echo "dns_rfc2136_secret = " "$(bashio::config 'dns_rfc2136_secret')" >> /data/dnsapikey
echo "dns_rfc2136_algorithm = " "$(bashio::config 'dns_rfc2136_algorithm')" >> /data/dnsapikey
echo "aws_access_key_id = " "$(bashio::config 'aws_access_key_id')" >> /data/dnsapikey
echo "aws_secret_access_key = " "$(bashio::config 'aws_secret_access_key')" >> /data/dnsapikey
echo "dns_sakuracloud_api_token = " "$(bashio::config 'dns_sakuracloud_api_token') ">> /data/dnsapikey
echo "dns_sakuracloud_api_secret = " "$(bashio::config 'dns_sakuracloud_api_secret')" >> /data/dnsapikey
chmod 600 /data/dnsapikey

bashio::log.info $"cat /data/dnsapikey"

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