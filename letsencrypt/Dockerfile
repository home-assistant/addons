ARG BUILD_FROM
FROM homeassistant/amd64-base-python:3.7

# setup base
ARG CERTBOT_VERSION

RUN apk add --no-cache --update \
        openssl libffi musl libstdc++ wget tar python python-dev py-pip gcc \
    && apk add --no-cache --virtual .build-dependencies \
    	g++ musl-dev openssl-dev libffi-dev \
    && pip3 install --no-cache-dir certbot==0.38.0 \
    && apk del .build-dependencies

# Install the DNS plugin
RUN pip3 install certbot-dns-cloudflare==0.38.0 \
&& pip3 install certbot-dns-cloudxns==0.38.0 \
&& pip3 install certbot-dns-digitalocean==0.38.0 \
&& pip3 install certbot-dns-dnsimple==0.38.0 \
&& pip3 install certbot-dns-dnsmadeeasy==0.38.0 \
&& pip3 install certbot-dns-gehirn==0.38.0 \
&& pip3 install certbot-dns-google==0.38.0 \
&& pip3 install certbot-dns-linode==0.38.0 \
&& pip3 install certbot-dns-luadns==0.38.0 \
&& pip3 install certbot-dns-nsone==0.38.0 \
&& pip3 install certbot-dns-ovh==0.38.0 \
&& pip3 install certbot-dns-rfc2136==0.38.0 \
&& pip3 install certbot-dns-route53==0.38.0 \
&& pip3 install certbot-dns-sakuracloud==0.38.0


# Copy data
COPY run.sh /

CMD [ "/run.sh" ]
