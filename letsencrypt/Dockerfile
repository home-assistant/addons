ARG BUILD_FROM
FROM $BUILD_FROM

# setup base
ARG CERTBOT_VERSION
ARG CERTBOT_DNS_DIRECTADMIN_VERSION
ARG CERTBOT_NETCUP_VERSION
ARG CERTBOT_NJALLA_VERSION
ARG CERTBOT_GANDI_VERSION
ARG CERTBOT_DNS_TRANSIP_VERSION
ARG CERTBOT_DNS_GODADDY_VERSION

RUN apk add --no-cache --update \
        libffi \
        musl \
        openssl \
    && apk add --no-cache --virtual .build-dependencies \
        g++ \
        libffi-dev \
        musl-dev \
        openssl-dev \
    && pip3 install setuptools==57.5.0 \
    && echo "cffi==1.14.6" >> /tmp/requirements.txt \
    && echo "cryptography==3.4.8" >> /tmp/requirements.txt \
    && echo "setuptools==57.5.0" >> /tmp/requirements.txt \
    && apkArch="$(apk --print-arch)"; \
       case "$apkArch" in \
         armhf) export ARCH='armhf' ;; \
         x86) export ARCH='i386' ;; \
         armv7) export ARCH='armv7' ;; \
         x86_64) export ARCH='amd64' ;; \
         aarch64) export ARCH='aarch64' ;; \
        esac \
    && pip3 install --no-cache-dir --find-links \
        "https://wheels.home-assistant.io/alpine-$(cut -d '.' -f 1-2 < /etc/alpine-release)/${ARCH}/" \
        certbot==${CERTBOT_VERSION} \
        certbot-dns-cloudflare==${CERTBOT_VERSION} \
        certbot-dns-cloudxns==${CERTBOT_VERSION} \
        certbot-dns-digitalocean==${CERTBOT_VERSION} \
        certbot-dns-directadmin==${CERTBOT_DNS_DIRECTADMIN_VERSION} \
        certbot-dns-dnsimple==${CERTBOT_VERSION} \
        certbot-dns-dnsmadeeasy==${CERTBOT_VERSION} \
        certbot-dns-gehirn==${CERTBOT_VERSION} \
        certbot-dns-google==${CERTBOT_VERSION} \
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
        certbot-dns-godaddy==${CERTBOT_DNS_GODADDY_VERSION} \
        -c /tmp/requirements.txt \
    && apk del .build-dependencies

# Copy data
COPY rootfs /
