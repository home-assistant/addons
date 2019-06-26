ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
RUN apk add --no-cache \
    bash-completion \
    curl \
    git \
    mosquitto-clients \
    nano \
    openssh \
    pwgen \
    tmux \
    vim

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
    && /usr/bin/hassio completion > /usr/share/bash-completion/completions/hassio

# Copy data
COPY data/run.sh /
COPY data/motd /etc/
COPY data/sshd_config /etc/ssh/

CMD [ "/run.sh" ]
