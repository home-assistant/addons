#!/usr/bin/env bashio

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

echo -e "dns_cloudflare_email = " "$(bashio::config 'dns_cloudflare_email')" "\n" \
  "dns_cloudflare_api_key = " "$(bashio::config 'dns_cloudflare_api_key')" "\n" \
  "dns_cloudxns_api_key = " "$(bashio::config 'dns_cloudxns_api_key')" "\n" \
  "dns_cloudxns_secret_key = " "$(bashio::config 'dns_cloudxns_secret_key')" "\n" \
  "dns_digitalocean_token = " "$(bashio::config 'dns_digitalocean_token')" "\n" \
  "dns_dnsimple_token = " "$(bashio::config 'dns_dnsimple_token')" "\n" \
  "dns_dnsmadeeasy_api_key = " "$(bashio::config 'dns_dnsmadeeasy_api_key')" "\n" \
  "dns_dnsmadeeasy_secret_key = " "$(bashio::config 'dns_dnsmadeeasy_secret_key')" "\n" \
  "dns_gehirn_api_token = " "$(bashio::config 'dns_gehirn_api_token')" "\n" \
  "dns_gehirn_api_secret = " "$(bashio::config 'dns_gehirn_api_secret')" "\n" \
  "dns_linode_key = " "$(bashio::config 'dns_linode_key')" "\n" \
  "dns_linode_version = " "$(bashio::config 'dns_linode_version')" "\n" \
  "dns_luadns_email = " "$(bashio::config 'dns_luadns_email')" "\n" \
  "dns_luadns_token = " "$(bashio::config 'dns_luadns_token')" "\n" \
  "dns_nsone_api_key = " "$(bashio::config 'dns_nsone_api_key')" "\n" \
  "dns_ovh_endpoint = " "$(bashio::config 'dns_ovh_endpoint')" "\n" \
  "dns_ovh_application_key = " "$(bashio::config 'dns_ovh_application_key')" "\n" \
  "dns_ovh_application_secret = " "$(bashio::config 'dns_ovh_application_secret')" "\n" \
  "dns_ovh_consumer_key = " "$(bashio::config 'dns_ovh_consumer_key')" "\n" \
  "dns_rfc2136_server = " "$(bashio::config 'dns_rfc2136_server')" "\n" \
  "dns_rfc2136_port = " "$(bashio::config 'dns_rfc2136_port')" "\n" \
  "dns_rfc2136_name = " "$(bashio::config 'dns_rfc2136_name')" "\n" \
  "dns_rfc2136_secret = " "$(bashio::config 'dns_rfc2136_secret')" "\n" \
  "dns_rfc2136_algorithm = " "$(bashio::config 'dns_rfc2136_algorithm')" "\n" \
  "aws_access_key_id = " "$(bashio::config 'aws_access_key_id')" "\n" \
  "aws_secret_access_key = " "$(bashio::config 'aws_secret_access_key')" "\n" \
  "dns_sakuracloud_api_token = " "$(bashio::config 'dns_sakuracloud_api_token')" "\n" \
  "dns_sakuracloud_api_secret = " "$(bashio::config 'dns_sakuracloud_api_secret')" >> /data/dnsapikey
chmod 600 /data/dnsapikey

bashio::log.info $"cat /data/dnsapikey"

# Generate new certs
if [ ! -d "$CERT_DIR/live" ]; then
    DOMAIN_ARR=()
    for line in $DOMAINS; do
        DOMAIN_ARR+=(-d "$line")
    done

    echo "$DOMAINS" > /data/domains.gen
    if [ "$CHALLENGE" == "dns" ]; then
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