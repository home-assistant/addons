ARG BUILD_FROM
FROM $BUILD_FROM

# setup base
ARG CERTBOT_VERSION

RUN apk add --no-cache --update \
        openssl libffi musl libstdc++ wget tar python python-dev py-pip gcc \
    && apk add --no-cache --virtual .build-dependencies \
    	g++ musl-dev openssl-dev libffi-dev \
    && pip3 install --no-cache-dir certbot==${CERTBOT_VERSION} \
    && apk del .build-dependencies

# Install the DNS plugin
RUN pip3 install certbot-dns-cloudflare
&& pip3 install certbot-dns-cloudxns \
&& pip3 install certbot-dns-digitalocean \
&& pip3 install certbot-dns-dnsimple \
&& pip3 install certbot-dns-dnsmadeeasy \
&& pip3 install certbot-dns-gehirn \
&& pip3 install certbot-dns-google \
&& pip3 install certbot-dns-linode \
&& pip3 install certbot-dns-luadns \
&& pip3 install certbot-dns-nsone \
&& pip3 install certbot-dns-ovh \
&& pip3 install certbot-dns-rfc2136 \
&& pip3 install certbot-dns-route53 \
&& pip3 install certbot-dns-sakuracloud


# Copy data
COPY run.sh /

CMD [ "/run.sh" ]
