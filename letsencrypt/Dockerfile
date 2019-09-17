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
RUN pip3 install certbot-dns-cloudflare==${CERTBOT_VERSION} \
&& pip3 install certbot-dns-cloudxns==${CERTBOT_VERSION} \
&& pip3 install certbot-dns-digitalocean==${CERTBOT_VERSION} \
&& pip3 install certbot-dns-dnsimple==${CERTBOT_VERSION} \
&& pip3 install certbot-dns-dnsmadeeasy==${CERTBOT_VERSION} \
&& pip3 install certbot-dns-gehirn==${CERTBOT_VERSION} \
&& pip3 install certbot-dns-google==${CERTBOT_VERSION} \
&& pip3 install certbot-dns-linode==${CERTBOT_VERSION} \
&& pip3 install certbot-dns-luadns==${CERTBOT_VERSION} \
&& pip3 install certbot-dns-nsone==${CERTBOT_VERSION} \
&& pip3 install certbot-dns-ovh==${CERTBOT_VERSION} \
&& pip3 install certbot-dns-rfc2136==${CERTBOT_VERSION} \
&& pip3 install certbot-dns-route53==${CERTBOT_VERSION} \
&& pip3 install certbot-dns-sakuracloud==${CERTBOT_VERSION}


# Copy data
COPY run.sh /

CMD [ "/run.sh" ]
