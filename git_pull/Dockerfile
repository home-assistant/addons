ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
RUN apk add --no-cache jq curl git openssh-client

# Hass.io CLI
ARG BUILD_ARCH
ARG CLI_VERSION
RUN apk add --no-cache curl \
    && curl -Lso /usr/bin/hassio https://github.com/home-assistant/hassio-cli/releases/download/${CLI_VERSION}/hassio_${BUILD_ARCH} \
    && chmod a+x /usr/bin/hassio

# Copy data
COPY run.sh /

CMD [ "/run.sh" ]
