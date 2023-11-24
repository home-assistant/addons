ARG BUILD_FROM
FROM $BUILD_FROM

# setup base
ARG \
    BUILD_ARCH \
    CRYPTOGRAPHY_VERSION \
    CERTBOT_VERSION \
    CERTBOT_DNS_AZURE_VERSION \
    CERTBOT_DNS_DIRECTADMIN_VERSION \
    CERTBOT_DNS_GOOGLE_DOMAINS_VERSION \
    CERTBOT_DNS_HETZNER_VERSION \
    CERTBOT_DNS_INWX_VERSION \
    CERTBOT_DNS_TRANSIP_VERSION \
    CERTBOT_NETCUP_VERSION \
    CERTBOT_NJALLA_VERSION \
    CERTBOT_GANDI_VERSION \
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
        cryptography==${CRYPTOGRAPHY_VERSION} \
        certbot==${CERTBOT_VERSION} \
        certbot-dns-azure==${CERTBOT_DNS_AZURE_VERSION} \
        certbot-dns-cloudflare==${CERTBOT_VERSION} \
        certbot-dns-digitalocean==${CERTBOT_VERSION} \
        certbot-dns-directadmin==${CERTBOT_DNS_DIRECTADMIN_VERSION} \
        certbot-dns-dnsimple==${CERTBOT_VERSION} \
        certbot-dns-dnsmadeeasy==${CERTBOT_VERSION} \
        certbot-dns-gehirn==${CERTBOT_VERSION} \
        certbot-dns-google==${CERTBOT_VERSION} \
        certbot-dns-google-domains==${CERTBOT_DNS_GOOGLE_DOMAINS_VERSION} \
        certbot-dns-hetzner==${CERTBOT_DNS_HETZNER_VERSION} \
        certbot-dns-linode==${CERTBOT_VERSION} \
        certbot-dns-luadns==${CERTBOT_VERSION} \
        certbot-dns-njalla==${CERTBOT_NJALLA_VERSION} \
        certbot-dns-nsone==${CERTBOT_VERSION} \
        certbot-dns-ovh==${CERTBOT_VERSION} \
        certbot-dns-rfc2136==${CERTBOT_VERSION} \
        certbot-dns-route53==${CERTBOT_VERSION} \
        certbot-dns-sakuracloud==${CERTBOT_VERSION} \
        certbot-dns-netcup==${CERTBOT_NETCUP_VERSION} \
        certbot-plugin-gandi==${CERTBOT_GANDI_VERSION} \
        certbot-dns-transip==${CERTBOT_DNS_TRANSIP_VERSION} \
        certbot-dns-inwx==${CERTBOT_DNS_INWX_VERSION} \
        acme==${ACME_VERSION} \
    && apk del .build-dependencies

# Copy data
COPY rootfs /
