#!/usr/bin/with-contenv bashio
# ==============================================================================
# Init folder & structures
# ==============================================================================
mkdir -p /data/workdir
mkdir -p /data/letsencrypt

# Setup Let's encrypt config
echo -e "dns_desec_token = $(bashio::config 'dns.desec_token')\n" \
      "dns_digitalocean_token = $(bashio::config 'dns.digitalocean_token')\n" \
      "dns_directadmin_url = $(bashio::config 'dns.directadmin_url')\n" \
      "dns_directadmin_username = $(bashio::config 'dns.directadmin_username')\n" \
      "dns_directadmin_password = $(bashio::config 'dns.directadmin_password')\n" \
      "dns_dnsimple_token = $(bashio::config 'dns.dnsimple_token')\n" \
      "dns_dnsmadeeasy_api_key = $(bashio::config 'dns.dnsmadeeasy_api_key')\n" \
      "dns_dnsmadeeasy_secret_key = $(bashio::config 'dns.dnsmadeeasy_secret_key')\n" \
      "dns_duckdns_token = $(bashio::config 'dns.duckdns_token')\n" \
      "dns_dynu_auth_token = $(bashio::config 'dns.dynu_auth_token')\n" \
      "dns_gehirn_api_token = $(bashio::config 'dns.gehirn_api_token')\n" \
      "dns_gehirn_api_secret = $(bashio::config 'dns.gehirn_api_secret')\n" \
      "dns_godaddy_secret = $(bashio::config 'dns.godaddy_secret')\n" \
      "dns_godaddy_key = $(bashio::config 'dns.godaddy_key')\n" \
      "dns_hetzner_api_token = $(bashio::config 'dns.hetzner_api_token')\n" \
      "dns_infomaniak_token = $(bashio::config 'dns.infomaniak_api_token')\n" \
      "dns_ionos_prefix = $(bashio::config 'dns.ionos_prefix')\n" \
      "dns_ionos_secret = $(bashio::config 'dns.ionos_secret')\n" \
      "dns_ionos_endpoint = $(bashio::config 'dns.ionos_endpoint')\n" \
      "dns_joker_username = $(bashio::config 'dns.joker_username')\n" \
      "dns_joker_password = $(bashio::config 'dns.joker_password')\n" \
      "dns_joker_domain = $(bashio::config 'dns.joker_domain')\n" \
      "dns_plesk_username = $(bashio::config 'dns.plesk_username')\n" \
      "dns_plesk_password = $(bashio::config 'dns.plesk_password')\n" \
      "dns_plesk_api_url = $(bashio::config 'dns.plesk_api_url')\n" \
      "dns_linode_key = $(bashio::config 'dns.linode_key')\n" \
      "dns_linode_version = $(bashio::config 'dns.linode_version')\n" \
      "dns_luadns_email = $(bashio::config 'dns.luadns_email')\n" \
      "dns_luadns_token = $(bashio::config 'dns.luadns_token')\n" \
      "dns_namecheap_username = $(bashio::config 'dns.namecheap_username')\n" \
      "dns_namecheap_api_key = $(bashio::config 'dns.namecheap_api_key')\n" \
      "dns_netcup_customer_id = $(bashio::config 'dns.netcup_customer_id')\n" \
      "dns_netcup_api_key = $(bashio::config 'dns.netcup_api_key')\n" \
      "dns_netcup_api_password = $(bashio::config 'dns.netcup_api_password')\n" \
      "dns_simply_account_name = $(bashio::config 'dns.simply_account_name')\n" \
      "dns_simply_api_key = $(bashio::config 'dns.simply_api_key')\n" \
      "dns_njalla_token = $(bashio::config 'dns.njalla_token')\n" \
      "dns_noris_token = $(bashio::config 'dns.noris_token')\n" \
      "dns_nsone_api_key = $(bashio::config 'dns.nsone_api_key')\n" \
      "dns_porkbun_key = $(bashio::config 'dns.porkbun_key')\n" \
      "dns_porkbun_secret = $(bashio::config 'dns.porkbun_secret')\n" \
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
      "dns_transip_username = $(bashio::config 'dns.transip_username')\n" \
      "dns_transip_key_file = /data/transip-rsa.key\n" \
      "dns_inwx_url = https://api.domrobot.com/xmlrpc/\n" \
      "dns_inwx_username = $(bashio::config 'dns.inwx_username')\n" \
      "dns_inwx_password = $(bashio::config 'dns.inwx_password')\n" \
      "dns_inwx_shared_secret = $(bashio::config 'dns.inwx_shared_secret')\n" \
      "dns_cloudns_auth_password = $(bashio::config 'dns.cloudns_auth_password')\n" \
      "dns_dreamhost_baseurl = $(bashio::config 'dns.dreamhost_baseurl')\n" \
      "dns_dreamhost_api_key = $(bashio::config 'dns.dreamhost_api_key')\n" \
      "dns_he_user = $(bashio::config 'dns.he_user')\n" \
      "dns_he_pass = $(bashio::config 'dns.he_pass')\n" \
      "dns_easydns_endpoint = $(bashio::config 'dns.easydns_endpoint')\n" \
      "dns_easydns_usertoken = $(bashio::config 'dns.easydns_token')\n" \
      "dns_easydns_userkey = $(bashio::config 'dns.easydns_key')\n" \
      "dns_domainoffensive_api_token = $(bashio::config 'dns.domainoffensive_token')\n" \
      "dns_websupport_identifier = $(bashio::config 'dns.websupport_identifier')\n" \
      "dns_websupport_secret_key = $(bashio::config 'dns.websupport_secret_key')\n" > /data/dnsapikey

# ClouDNS
# Only a single non-empty auth option must be in /data/dnsapikey when using ClouDNS to avoid a certbot error
if bashio::config.exists 'dns.cloudns_auth_id'; then
      echo -e "dns_cloudns_auth_id = $(bashio::config 'dns.cloudns_auth_id')\n" >> /data/dnsapikey
fi

if bashio::config.exists 'dns.cloudns_sub_auth_id'; then
      echo -e "dns_cloudns_sub_auth_id = $(bashio::config 'dns.cloudns_sub_auth_id')\n" >> /data/dnsapikey
fi

if bashio::config.exists 'dns.cloudns_sub_auth_user'; then
      echo -e "dns_cloudns_sub_auth_user = $(bashio::config 'dns.cloudns_sub_auth_user')\n" >> /data/dnsapikey
fi

chmod 600 /data/dnsapikey

## Prepare TransIP RSA key
if bashio::config.exists 'dns.transip_api_key'; then
      TRANSIP_API_KEY=$(bashio::config 'dns.transip_api_key')
      echo "${TRANSIP_API_KEY}" | openssl rsa -out /data/transip-rsa.key
      chmod 600 /data/transip-rsa.key
fi

# Cleanup removed add-on options
if bashio::config.exists 'dns.cloudxns_api_key'; then
      bashio::addon.option 'dns.cloudxns_api_key'
fi
if bashio::config.exists 'dns.cloudxns_secret_key'; then
      bashio::addon.option 'dns.cloudxns_secret_key'
fi
if bashio::config.exists 'keytype'; then
    bashio::addon.option 'keytype'
fi
if bashio::config.exists 'dns.google_domains_access_token'; then
    bashio::addon.option 'dns.google_domains_access_token'
fi
if bashio::config.exists 'dns.google_domains_zone'; then
    bashio::addon.option 'dns.google_domains_zone'
fi
