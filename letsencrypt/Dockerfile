ARG BUILD_FROM
FROM $BUILD_FROM

# setup base
ARG CERTBOT_VERSION

RUN apk add --no-cache --update \
        openssl libffi musl libstdc++ wget tar python python-dev py-pip gcc \
    && apk add --no-cache --virtual .build-dependencies g++ musl-dev openssl-dev libffi-dev

# Retrieve Certbot DNS plugin code
RUN wget -O certbot-$CERTBOT_VERSION.tar.gz https://github.com/certbot/certbot/archive/v$CERTBOT_VERSION.tar.gz \
 && tar xf certbot-$CERTBOT_VERSION.tar.gz \
 && mkdir -p /opt/certbot/src/ \
 && mkdir /data \
 && cp -r certbot-$CERTBOT_VERSION/certbot-dns* /opt/certbot/src/ \
 && rm -rf certbot-$CERTBOT_VERSION.tar.gz certbot-$CERTBOT_VERSION 

# Install the DNS plugin
RUN pip install --no-cache-dir --editable /opt/certbot/src/certbot-dns-cloudflare \
&& pip install --no-cache-dir --editable /opt/certbot/src/certbot-dns-cloudxns \
&& pip install --no-cache-dir --editable /opt/certbot/src/certbot-dns-digitalocean \
&& pip install --no-cache-dir --editable /opt/certbot/src/certbot-dns-dnsimple \
&& pip install --no-cache-dir --editable /opt/certbot/src/certbot-dns-dnsmadeeasy \
&& pip install --no-cache-dir --editable /opt/certbot/src/certbot-dns-gehirn \
&& pip install --no-cache-dir --editable /opt/certbot/src/certbot-dns-google \
&& pip install --no-cache-dir --editable /opt/certbot/src/certbot-dns-linode \
&& pip install --no-cache-dir --editable /opt/certbot/src/certbot-dns-luadns \
&& pip install --no-cache-dir --editable /opt/certbot/src/certbot-dns-nsone \
&& pip install --no-cache-dir --editable /opt/certbot/src/certbot-dns-ovh \
&& pip install --no-cache-dir --editable /opt/certbot/src/certbot-dns-rfc2136 \
&& pip install --no-cache-dir --editable /opt/certbot/src/certbot-dns-route53 \
&& pip install --no-cache-dir --editable /opt/certbot/src/certbot-dns-sakuracloud


# Copy data
COPY run.sh /

CMD [ "/run.sh" ]
