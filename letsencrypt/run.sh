#!/usr/bin/env bashio

EMAIL=$(bashio::config 'email')
DOMAINS=$(bashio::config 'domains')
KEYFILE=$(bashio::config 'keyfile')
CERTFILE=$(bashio::config 'certfile')
CHALLENGE=$(bashio::config 'challenge')
DNS_PROVIDER=$(bashio::config 'dns.provider // empty')

CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir

mkdir -p "$WORK_DIR"
mkdir -p "$CERT_DIR"
mkdir -p "/ssl"
chmod +x /run.sh
touch /data/dnsapikey

echo -e "dns_cloudflare_email = " "$(bashio::config 'dns.cloudflare_email // empty')" "\n" \
  "dns_cloudflare_api_key = " "$(bashio::config 'dns.cloudflare_api_key // empty')" "\n" \
  "dns_cloudxns_api_key = " "$(bashio::config 'dns.cloudxns_api_key // empty')" "\n" \
  "dns_cloudxns_secret_key = " "$(bashio::config 'dns.cloudxns_secret_key // empty')" "\n" \
  "dns_digitalocean_token = " "$(bashio::config 'dns.digitalocean_token // empty')" "\n" \
  "dns_dnsimple_token = " "$(bashio::config 'dns.dnsimple_token // empty')" "\n" \
  "dns_dnsmadeeasy_api_key = " "$(bashio::config 'dns.dnsmadeeasy_api_key // empty')" "\n" \
  "dns_dnsmadeeasy_secret_key = " "$(bashio::config 'dns.dnsmadeeasy_secret_key // empty')" "\n" \
  "dns_gehirn_api_token = " "$(bashio::config 'dns.gehirn_api_token // empty')" "\n" \
  "dns_gehirn_api_secret = " "$(bashio::config 'dns.gehirn_api_secret // empty')" "\n" \
  "dns_linode_key = " "$(bashio::config 'dns.linode_key // empty')" "\n" \
  "dns_linode_version = " "$(bashio::config 'dns.linode_version // empty')" "\n" \
  "dns_luadns_email = " "$(bashio::config 'dns.luadns_email // empty')" "\n" \
  "dns_luadns_token = " "$(bashio::config 'dns.luadns_token // empty')" "\n" \
  "dns_nsone_api_key = " "$(bashio::config 'dns.nsone_api_key // empty')" "\n" \
  "dns_ovh_endpoint = " "$(bashio::config 'dns.ovh_endpoint // empty')" "\n" \
  "dns_ovh_application_key = " "$(bashio::config 'dns.ovh_application_key // empty')" "\n" \
  "dns_ovh_application_secret = " "$(bashio::config 'dns.ovh_application_secret // empty')" "\n" \
  "dns_ovh_consumer_key = " "$(bashio::config 'dns.ovh_consumer_key // empty')" "\n" \
  "dns_rfc2136_server = " "$(bashio::config 'dns.rfc2136_server // empty')" "\n" \
  "dns_rfc2136_port = " "$(bashio::config 'dns.rfc2136_port // empty')" "\n" \
  "dns_rfc2136_name = " "$(bashio::config 'dns.rfc2136_name // empty')" "\n" \
  "dns_rfc2136_secret = " "$(bashio::config 'dns.rfc2136_secret // empty')" "\n" \
  "dns_rfc2136_algorithm = " "$(bashio::config 'dns.rfc2136_algorithm // empty')" "\n" \
  "aws_access_key_id = " "$(bashio::config 'dns.aws_access_key_id // empty')" "\n" \
  "aws_secret_access_key = " "$(bashio::config 'dns.aws_secret_access_key // empty')" "\n" \
  "dns_sakuracloud_api_token = " "$(bashio::config 'dns.sakuracloud_api_token // empty')" "\n" \
  "dns_sakuracloud_api_secret = " "$(bashio::config 'dns.sakuracloud_api_secret // empty')" > /data/dnsapikey
chmod 600 /data/dnsapikey

# Generate new certs
if [ ! -d "$CERT_DIR/live" ]; then
    DOMAIN_ARR=()
    for line in $DOMAINS; do
        DOMAIN_ARR+=(-d "$line")
    done

    echo "$DOMAINS" > /data/domains.gen
    if [ "$CHALLENGE" == "dns" ]; then
        certbot certonly --non-interactive --config-dir "$CERT_DIR" --work-dir "$WORK_DIR" --"$DNS_PROVIDER" --"$DNS_PROVIDER"-credentials "/data/dnsapikey" --email "$EMAIL" --agree-tos --config-dir "$CERT_DIR" --work-dir "$WORK_DIR" --preferred-challenges "$CHALLENGE" "${DOMAIN_ARR[@]}"
    else
        certbot certonly --non-interactive --standalone --email "$EMAIL" --agree-tos --config-dir "$CERT_DIR" --work-dir "$WORK_DIR" --preferred-challenges "$CHALLENGE" "${DOMAIN_ARR[@]}"
    fi
else
    certbot renew --non-interactive --config-dir "$CERT_DIR" --work-dir "$WORK_DIR" --preferred-challenges "$CHALLENGE"
fi

# copy certs to store
cp "$CERT_DIR"/live/*/privkey.pem "/ssl/$KEYFILE"
cp "$CERT_DIR"/live/*/fullchain.pem "/ssl/$CERTFILE"
