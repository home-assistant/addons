ARG BUILD_FROM
FROM $BUILD_FROM

WORKDIR /usr/src

# Setup base
ARG CONFIGURATOR_VERSION
RUN apk add --no-cache \
      git curl openssh \
  && pip3 install --no-cache-dir GitPython pyotp \
  && curl -s -o /configurator.py https://raw.githubusercontent.com/danielperna84/hass-configurator/$CONFIGURATOR_VERSION/configurator.py \
  && apk del curl

# Setup HA Auth
ARG HASSIO_AUTH_VERSION
RUN apk add --no-cache \
        nginx nginx-mod-http-lua \
    && git clone --depth 1 -b $HASSIO_AUTH_VERSION https://github.com/home-assistant/hassio-auth \
    && cd hassio-auth/nginx-frontend \
    && cp -f * /etc/nginx/ \
    && rm -r /usr/src/hassio-auth

WORKDIR /

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
