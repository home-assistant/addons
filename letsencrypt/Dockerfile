ARG BUILD_FROM
FROM $BUILD_FROM

# setup base
ARG \
    BUILD_ARCH \
    CLOUDFLARE_VERSION \
    CRYPTOGRAPHY_VERSION \
    CERTBOT_VERSION \
    CERTBOT_DNS_AZURE_VERSION \
    CERTBOT_DNS_CLOUDNS_VERSION \
    CERTBOT_DNS_DESEC_VERSION \
    CERTBOT_DNS_DIRECTADMIN_VERSION \
    CERTBOT_DNS_DREAMHOST_VERSION \
    CERTBOT_DNS_DUCKDNS_VERSION \
    CERTBOT_DNS_DYNU_VERSION \
    CERTBOT_DNS_EASYDNS_VERSION \
    CERTBOT_DNS_HE_VERSION \
    CERTBOT_DNS_HETZNER_VERSION \
    CERTBOT_DNS_INFOMANIAK_VERSION \
    CERTBOT_DNS_INWX_VERSION \
    CERTBOT_DNS_IONOS_VERSION \
    CERTBOT_DNS_JOKER_VERSION \
    CERTBOT_DNS_NAMECHEAP_VERSION \
    CERTBOT_DNS_NORISNETWORK_VERSION \
    CERTBOT_DNS_SIMPLY_VERSION \
    CERTBOT_DNS_TRANSIP_VERSION \
    CERTBOT_DNS_PORKBUN_VERSION \
    CERTBOT_DNS_WEBSUPPORT_VERSION \
    CERTBOT_NETCUP_VERSION \
    CERTBOT_NJALLA_VERSION \
    CERTBOT_GANDI_VERSION \
    CERTBOT_DNS_DOMAINOFFENSIVE_VERSION \
    CERTBOT_DNS_PLESK_VERSION \
    CERTBOT_DNS_GODADDY_VERSION \
    ACME_VERSION

RUN \
    set -x \
    && apk add --no-cache --update \
        libffi \
        musl \
        openssl \
    && apk add --no-cache --virtual .build-dependencies \
        build-base \
        libffi-dev \
        musl-dev \
        openssl-dev \
        cargo \
    && pip3 install --no-cache-dir --find-links \
        "https://wheels.home-assistant.io/alpine-$(cut -d '.' -f 1-2 < /etc/alpine-release)/${BUILD_ARCH}/" \
        cloudflare==${CLOUDFLARE_VERSION} \
        cryptography==${CRYPTOGRAPHY_VERSION} \
        certbot==${CERTBOT_VERSION} \
        certbot-dns-azure==${CERTBOT_DNS_AZURE_VERSION} \
        certbot-dns-cloudflare==${CERTBOT_VERSION} \
        certbot-dns-cloudns==${CERTBOT_DNS_CLOUDNS_VERSION} \
        certbot-dns-desec==${CERTBOT_DNS_DESEC_VERSION} \
        certbot-dns-digitalocean==${CERTBOT_VERSION} \
        certbot-dns-directadmin==${CERTBOT_DNS_DIRECTADMIN_VERSION} \
        certbot-dns-dnsimple==${CERTBOT_VERSION} \
        certbot-dns-dnsmadeeasy==${CERTBOT_VERSION} \
        certbot-dns-duckdns==${CERTBOT_DNS_DUCKDNS_VERSION} \
        certbot-dns-dynu-dev==${CERTBOT_DNS_DYNU_VERSION} \
        certbot-dns-gehirn==${CERTBOT_VERSION} \
        certbot-dns-godaddy==${CERTBOT_DNS_GODADDY_VERSION} \
        certbot-dns-google==${CERTBOT_VERSION} \
        certbot-dns-hetzner==${CERTBOT_DNS_HETZNER_VERSION} \
        certbot-dns-infomaniak==${CERTBOT_DNS_INFOMANIAK_VERSION} \
        certbot-dns-ionos==${CERTBOT_DNS_IONOS_VERSION} \
        certbot-dns-joker==${CERTBOT_DNS_JOKER_VERSION} \
        certbot-dns-linode==${CERTBOT_VERSION} \
        certbot-dns-luadns==${CERTBOT_VERSION} \
        certbot-dns-njalla==${CERTBOT_NJALLA_VERSION} \
        certbot-dns-norisnetwork==${CERTBOT_DNS_NORISNETWORK_VERSION} \
        certbot-dns-nsone==${CERTBOT_VERSION} \
        certbot-dns-porkbun==${CERTBOT_DNS_PORKBUN_VERSION} \
        certbot-dns-ovh==${CERTBOT_VERSION} \
        certbot-dns-rfc2136==${CERTBOT_VERSION} \
        certbot-dns-route53==${CERTBOT_VERSION} \
        certbot-dns-sakuracloud==${CERTBOT_VERSION} \
        certbot-dns-namecheap==${CERTBOT_DNS_NAMECHEAP_VERSION} \
        certbot-dns-simply==${CERTBOT_DNS_SIMPLY_VERSION} \
        certbot-dns-netcup==${CERTBOT_NETCUP_VERSION} \
        certbot-plugin-gandi==${CERTBOT_GANDI_VERSION} \
        certbot-dns-transip==${CERTBOT_DNS_TRANSIP_VERSION} \
        certbot-dns-inwx==${CERTBOT_DNS_INWX_VERSION} \
        certbot-dns-dreamhost==${CERTBOT_DNS_DREAMHOST_VERSION} \
        certbot-dns-he==${CERTBOT_DNS_HE_VERSION} \
        certbot-dns-easydns==${CERTBOT_DNS_EASYDNS_VERSION} \
        certbot-dns-domainoffensive==${CERTBOT_DNS_DOMAINOFFENSIVE_VERSION} \
        certbot-dns-websupport==${CERTBOT_DNS_WEBSUPPORT_VERSION} \
        certbot-dns-plesk==${CERTBOT_DNS_PLESK_VERSION} \
        acme==${ACME_VERSION} \
    && apk del .build-dependencies

# Copy data
COPY rootfs /
