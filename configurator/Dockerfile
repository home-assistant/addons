ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
ARG CONFIGURATOR_VERSION
RUN apk add --no-cache \
        git \
        openssh-client \
    && pip install --no-cache-dir \
        hass-configurator==${CONFIGURATOR_VERSION}

# Copy data
COPY data/configurator.conf /etc/
COPY data/run.sh /

CMD ["/run.sh"]
