ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache \
    openssh vim curl nano git mosquitto-clients tmux \
    bash-completion

# Replace bash as default shell
RUN sed -i "s/ash/bash/" /etc/passwd

# Add YAML highlighting for nano
ADD https://raw.githubusercontent.com/scopatz/nanorc/master/yaml.nanorc /usr/share/nano/yaml.nanorc
RUN sed -i 's/^#[[:space:]]*\(include "\/usr\/share\/nano\/\*\.nanorc".*\)/\1/' /etc/nanorc

# Hass.io CLI
ARG BUILD_ARCH
ARG CLI_VERSION
RUN apk add --no-cache curl \
    && curl -Lso /usr/bin/hassio https://github.com/home-assistant/hassio-cli/releases/download/${CLI_VERSION}/hassio_${BUILD_ARCH} \
    && chmod a+x /usr/bin/hassio \
    && curl -Lso /usr/share/bash-completion/completions/hassio https://raw.githubusercontent.com/home-assistant/hassio-cli/${CLI_VERSION}/hassio.bash

# Copy data
COPY run.sh /
COPY motd /etc/

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
