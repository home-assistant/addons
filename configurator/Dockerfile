ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
ARG CONFIGURATOR_VERSION
ARG HASSIO_AUTH_VERSION
RUN apk add --no-cache \
    git nginx nginx-mod-http-lua \
  && git clone --depth 1 -b ${HASSIO_AUTH_VERSION} https://github.com/home-assistant/hassio-auth \
  && cp -f hassio-auth/nginx-frontend/* /etc/nginx/ \
  && rm -fr /usr/src/hassio-auth \
  && pip install hass-configurator==${CONFIGURATOR_VERSION}

# Copy data
COPY configurator.conf /etc/
COPY run.sh /

CMD ["/run.sh"]
