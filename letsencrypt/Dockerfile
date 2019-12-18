ARG BUILD_FROM
FROM $BUILD_FROM

# setup base
ARG CERTBOT_VERSION

RUN apk add --no-cache --update \
        libffi \
        musl \
        openssl \
    && apk add --no-cache --virtual .build-dependencies \
        g++ \
        libffi-dev \
        musl-dev \
        openssl-dev \
    && pip3 install --no-cache-dir certbot==${CERTBOT_VERSION} \
        certbot-dns-cloudflare==${CERTBOT_VERSION} \
        certbot-dns-cloudxns==${CERTBOT_VERSION} \
        certbot-dns-digitalocean==${CERTBOT_VERSION} \
        certbot-dns-dnsimple==${CERTBOT_VERSION} \
        certbot-dns-dnsmadeeasy==${CERTBOT_VERSION} \
        certbot-dns-gehirn==${CERTBOT_VERSION} \
        certbot-dns-google==${CERTBOT_VERSION} \
        certbot-dns-linode==${CERTBOT_VERSION} \
        certbot-dns-luadns==${CERTBOT_VERSION} \
        certbot-dns-nsone==${CERTBOT_VERSION} \
        certbot-dns-ovh==${CERTBOT_VERSION} \
        certbot-dns-rfc2136==${CERTBOT_VERSION} \
        certbot-dns-route53==${CERTBOT_VERSION} \
        certbot-dns-sakuracloud==${CERTBOT_VERSION} \
    && apk del .build-dependencies

# Copy data
COPY data/run.sh /

CMD [ "/run.sh" ]
