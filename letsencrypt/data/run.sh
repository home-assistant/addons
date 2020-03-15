#!/usr/bin/env bashio

# shellcheck disable=SC1091
source "/opt/letsencrypt/lib/letsencrypt.sh"

EMAIL=$(bashio::config 'email')
DOMAINS=$(bashio::config 'domains')
CHALLENGE=$(bashio::config 'challenge')
DNS_PROVIDER=$(bashio::config 'dns.provider')
CERT_DIR=$(letsencrypt::cert_dir)
WORK_DIR=$(letsencrypt::work_dir)
SERVER_OPTIONS=$(letsencrypt::server_options)
RENEWAL_TIME=$(bashio::config 'renewal_check_time')
RENEWAL_CRONTAB=$(letsencrypt::crontab_convert "${RENEWAL_TIME}")

if [ "${CHALLENGE}" == "dns" ]; then
    bashio::log.info "Selected DNS Provider: ${DNS_PROVIDER}"

    PROPAGATION_SECONDS=60
    if bashio::config.exists 'dns.propagation_seconds'; then
        PROPAGATION_SECONDS="$(bashio::config 'dns.propagation_seconds')" 
    fi
    bashio::log.info "Use propagation seconds: ${PROPAGATION_SECONDS}"
else
    bashio::log.info "Selected http verification"
fi

mkdir -p "$WORK_DIR"
mkdir -p "$CERT_DIR"
mkdir -p "/ssl"
touch /data/dnsapikey
PROVIDER_ARGUMENTS=()

echo -e "dns_cloudxns_api_key = $(bashio::config 'dns.cloudxns_api_key')\n" \
      "dns_cloudxns_secret_key = $(bashio::config 'dns.cloudxns_secret_key')\n" \
      "dns_digitalocean_token = $(bashio::config 'dns.digitalocean_token')\n" \
      "dns_dnsimple_token = $(bashio::config 'dns.dnsimple_token')\n" \
      "dns_dnsmadeeasy_api_key = $(bashio::config 'dns.dnsmadeeasy_api_key')\n" \
      "dns_dnsmadeeasy_secret_key = $(bashio::config 'dns.dnsmadeeasy_secret_key')\n" \
      "dns_gehirn_api_token = $(bashio::config 'dns.gehirn_api_token')\n" \
      "dns_gehirn_api_secret = $(bashio::config 'dns.gehirn_api_secret')\n" \
      "dns_linode_key = $(bashio::config 'dns.linode_key')\n" \
      "dns_linode_version = $(bashio::config 'dns.linode_version')\n" \
      "dns_luadns_email = $(bashio::config 'dns.luadns_email')\n" \
      "dns_luadns_token = $(bashio::config 'dns.luadns_token')\n" \
      "certbot_dns_netcup:dns_netcup_customer_id = $(bashio::config 'dns.netcup_customer_id')\n" \
      "certbot_dns_netcup:dns_netcup_api_key = $(bashio::config 'dns.netcup_api_key')\n" \
      "certbot_dns_netcup:dns_netcup_api_password = $(bashio::config 'dns.netcup_api_password')\n" \
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
      "dns_sakuracloud_api_secret = $(bashio::config 'dns.sakuracloud_api_secret')" > /data/dnsapikey
chmod 600 /data/dnsapikey

# AWS
if bashio::config.exists 'dns.aws_access_key_id' && bashio::config.exists 'dns.aws_secret_access_key'; then
    AWS_ACCESS_KEY_ID="$(bashio::config 'dns.aws_access_key_id')"
    AWS_SECRET_ACCESS_KEY="$(bashio::config 'dns.aws_secret_access_key')"

    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    PROVIDER_ARGUMENTS+=("--${DNS_PROVIDER}")
#Google
elif bashio::config.exists 'dns.google_creds'; then
    GOOGLE_CREDS="$(bashio::config 'dns.google_creds')"

    export GOOGLE_CREDS
    if [ -f "/share/${GOOGLE_CREDS}" ]; then
      cp -f "/share/${GOOGLE_CREDS}" "/data/${GOOGLE_CREDS}"
      chmod 600 "/data/${GOOGLE_CREDS}"
    else
      bashio::log.info "Google Credentials File doesnt exists in folder share."
    fi
    PROVIDER_ARGUMENTS+=("--${DNS_PROVIDER}" "--${DNS_PROVIDER}-credentials" "/data/${GOOGLE_CREDS}")

#Netcup
elif bashio::config.exists 'dns.netcup_customer_id' && bashio::config.exists 'dns.netcup_api_key' && bashio::config.exists 'dns.netcup_api_password'; then
    PROVIDER_ARGUMENTS+=("--authenticator" "certbot-dns-netcup:dns-netcup" "--certbot-dns-netcup:dns-netcup-credentials" /data/dnsapikey "--certbot-dns-netcup:dns-netcup-propagation-seconds" "${PROPAGATION_SECONDS}")

# CloudFlare
elif [ "${DNS_PROVIDER}" == "dns-cloudflare" ]; then
    if bashio::config.exists 'dns.cloudflare_api_token'; then
        bashio::log.info "Use CloudFlare token"
        echo "dns_cloudflare_api_token = $(bashio::config 'dns.cloudflare_api_token')" >> /data/dnsapikey
    else
        bashio::log.warning "Use CloudFlare global key (not recommended!)"
        echo -e "dns_cloudflare_email = $(bashio::config 'dns.cloudflare_email')\n" \
            "dns_cloudflare_api_key = $(bashio::config 'dns.cloudflare_api_key')\n" >> /data/dnsapikey
    fi

    PROVIDER_ARGUMENTS+=("--${DNS_PROVIDER}" "--${DNS_PROVIDER}-credentials" /data/dnsapikey "--dns-cloudflare-propagation-seconds" "${PROPAGATION_SECONDS}")

#All others
else
    PROVIDER_ARGUMENTS+=("--${DNS_PROVIDER}" "--${DNS_PROVIDER}-credentials" /data/dnsapikey)
fi

# Generate new certs
DOMAIN_ARR=()
for line in $DOMAINS; do
    DOMAIN_ARR+=(-d "$line")
done

echo "$DOMAINS" > /data/domains.gen
if [ "$CHALLENGE" == "dns" ]; then
    certbot certonly --non-interactive --keep-until-expiring --expand \
    --email "$EMAIL" --agree-tos "${PROVIDER_ARGUMENTS[@]}" \
    --config-dir "$CERT_DIR" --work-dir "$WORK_DIR" \
    --preferred-challenges "$CHALLENGE" --deploy-hook "/deploy.sh" \
    --server "${SERVER_OPTIONS}"  "${DOMAIN_ARR[@]}"

else
    certbot certonly --non-interactive --keep-until-expiring --expand \
    --email "$EMAIL" --agree-tos  --config-dir "$CERT_DIR" \
    --work-dir "$WORK_DIR" --preferred-challenges "$CHALLENGE" \
    --deploy-hook "/deploy.sh" --server "${SERVER_OPTIONS}"  --standalone \
    "${DOMAIN_ARR[@]}"

fi

#Setup Environment for Cronjob
declare -p | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID|SUPERVISOR_TOKEN' > /data/container.env


if  bashio::config.exists  'renewal_daily_check' && bashio::config.true 'renewal_daily_check'; then
    bashio::log.info "Setting up daily renewal check at ${RENEWAL_TIME}"
    # Setup a cron schedule
    echo "SHELL=/bin/bash
    BASH_ENV=/data/container.env
    ${RENEWAL_CRONTAB} /renew.sh >> /dev/stdout 2>&1
    # This extra line makes it a valid cron" > /data/scheduler.txt

    crontab /data/scheduler.txt
    crond -f -d 8
fi
