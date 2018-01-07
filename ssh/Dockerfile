ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache \
    jq openssh vim curl nano git mosquitto-clients tmux \
    bash-completion

# Replace bash as default shell
RUN sed -i "s/ash/bash/" /etc/passwd

# Hass.io CLI
ARG BUILD_ARCH
ARG CLI_VERSION
RUN apk add --no-cache curl \
    && curl -Lso /usr/bin/hassio https://github.com/home-assistant/hassio-cli/releases/download/${CLI_VERSION}/hassio_${BUILD_ARCH}
    && chmod a+x /usr/bin/hassio

# Copy data
COPY run.sh /
COPY motd /etc/

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
