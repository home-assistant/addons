ARG BUILD_FROM
FROM $BUILD_FROM

# Allow pip to install packages system-wide on Debian
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# setup base
# certbot-dns-multi replaces most individual DNS plugins using lego
# Only legacy plugins are kept for providers not supported by lego: gehirn, eurodns, noris
# Azure and HE is also kept as legacy for backward compatibility (will be removed in future version)
ARG \
    BUILD_ARCH \
    ACME_VERSION \
    CERTBOT_DNS_AZURE_VERSION \
    CERTBOT_DNS_EURODNS_VERSION \
    CERTBOT_DNS_HURRICANE_ELECTRIC_VERSION \
    CERTBOT_DNS_MULTI_VERSION \
    CERTBOT_DNS_NORISNETWORK_VERSION \
    CERTBOT_VERSION \
    CRYPTOGRAPHY_VERSION

RUN \
    set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libffi8 \
        openssl \
        python3 \
        python3-pip \
        python3-dev \
        build-essential \
        libffi-dev \
        libssl-dev \
        cargo \
        rustc \
        golang \
    && pip3 install --no-cache-dir \
        acme==${ACME_VERSION} \
        certbot==${CERTBOT_VERSION} \
        certbot-dns-azure==${CERTBOT_DNS_AZURE_VERSION} \
        certbot-dns-eurodns==${CERTBOT_DNS_EURODNS_VERSION} \
        certbot-dns-gehirn==${CERTBOT_VERSION} \
        certbot-dns-hurricane-electric==${CERTBOT_DNS_HURRICANE_ELECTRIC_VERSION} \
        certbot-dns-multi==${CERTBOT_DNS_MULTI_VERSION} \
        certbot-dns-norisnetwork==${CERTBOT_DNS_NORISNETWORK_VERSION} \
        cryptography==${CRYPTOGRAPHY_VERSION} \
    && apt-get purge -y --auto-remove \
        build-essential \
        cargo \
        golang \
        libffi-dev \
        libssl-dev \
        rustc \
    && rm -rf /var/lib/apt/lists/*

# Copy data
COPY rootfs /
