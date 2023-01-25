#!/usr/bin/with-contenv bashio
# ==============================================================================
# Init folder & structures
# ==============================================================================
mkdir -p /data/workdir
mkdir -p /data/letsencrypt

# Setup Let's encrypt config
echo -e "dns_cloudxns_api_key = $(bashio::config 'dns.cloudxns_api_key')\n" \
      "dns_cloudxns_secret_key = $(bashio::config 'dns.cloudxns_secret_key')\n" \
      "dns_digitalocean_token = $(bashio::config 'dns.digitalocean_token')\n" \
      "certbot_dns_directadmin:directadmin_url = $(bashio::config 'dns.directadmin_url')\n" \
      "certbot_dns_directadmin:directadmin_username = $(bashio::config 'dns.directadmin_username')\n" \
      "certbot_dns_directadmin:directadmin_password = $(bashio::config 'dns.directadmin_password')\n" \
      "dns_dnsimple_token = $(bashio::config 'dns.dnsimple_token')\n" \
      "dns_dnsmadeeasy_api_key = $(bashio::config 'dns.dnsmadeeasy_api_key')\n" \
      "dns_dnsmadeeasy_secret_key = $(bashio::config 'dns.dnsmadeeasy_secret_key')\n" \
      "dns_gehirn_api_token = $(bashio::config 'dns.gehirn_api_token')\n" \
      "dns_gehirn_api_secret = $(bashio::config 'dns.gehirn_api_secret')\n" \
      "dns_hetzner_api_token = $(bashio::config 'dns.hetzner_api_token')\n" \
      "dns_linode_key = $(bashio::config 'dns.linode_key')\n" \
      "dns_linode_version = $(bashio::config 'dns.linode_version')\n" \
      "dns_luadns_email = $(bashio::config 'dns.luadns_email')\n" \
      "dns_luadns_token = $(bashio::config 'dns.luadns_token')\n" \
      "certbot_dns_netcup:dns_netcup_customer_id = $(bashio::config 'dns.netcup_customer_id')\n" \
      "certbot_dns_netcup:dns_netcup_api_key = $(bashio::config 'dns.netcup_api_key')\n" \
      "certbot_dns_netcup:dns_netcup_api_password = $(bashio::config 'dns.netcup_api_password')\n" \
      "certbot_dns_njalla:dns_njalla_token = $(bashio::config 'dns.njalla_token')\n" \
      "dns_nsone_api_key = $(bashio::config 'dns.nsone_api_key')\n" \
      "dns_ovh_endpoint = $(bashio::config 'dns.ovh_endpoint')\n" \
      "dns_ovh_application_key = $(bashio::config 'dns.ovh_application_key')\n" \
      "dns_ovh_application_secret = $(bashio::config 'dns.ovh_application_secret')\n" \
      "dns_ovh_consumer_key = $(bashio::config 'dns.ovh_consumer_key')\n" \
      "dns_rfc2136_server = $(bashio::config 'dns.rfc2136_server')\n" \
      "dns_rfc2136_port = $(bashio::config 'dns.rfc2136_port')\n" \
      "dns_rfc2136_name = $(bashio::config 'dns.rfc2136_name')\n" \
      "dns_rfc2136_secret = $(bashio::config 'dns.rfc2136_secret')\n" \
      "dns_rfc2136_algorithm = $(bashio::config 'dns.rfc2136_algorithm')\n" \
      "aws_access_key_id = $(bashio::config 'dns.aws_access_key_id')\n" \
      "aws_secret_access_key = $(bashio::config 'dns.aws_secret_access_key')\n" \
      "dns_sakuracloud_api_token = $(bashio::config 'dns.sakuracloud_api_token')\n" \
      "dns_sakuracloud_api_secret = $(bashio::config 'dns.sakuracloud_api_secret')\n" \
      "certbot_plugin_gandi:dns_api_key = $(bashio::config 'dns.gandi_api_key')\n" \
      "certbot_dns_transip:dns_transip_username = $(bashio::config 'dns.transip_username')\n" \
      "certbot_dns_transip:dns_transip_key_file = /data/transip-rsa.key\n" \
      "dns_inwx_url = https://api.domrobot.com/xmlrpc/\n" \
      "dns_inwx_username = $(bashio::config 'dns.inwx_username')\n" \
      "dns_inwx_password = $(bashio::config 'dns.inwx_password')\n" \
      "dns_inwx_shared_secret = $(bashio::config 'dns.inwx_shared_secret')" > /data/dnsapikey

chmod 600 /data/dnsapikey

## Prepare TransIP RSA key
if bashio::config.exists 'dns.transip_api_key'; then
      TRANSIP_API_KEY=$(bashio::config 'dns.transip_api_key')
      echo "${TRANSIP_API_KEY}" | openssl rsa -out /data/transip-rsa.key
      chmod 600 /data/transip-rsa.key
fi
