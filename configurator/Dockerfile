ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
ARG BUILD_ARCH
ARG CONFIGURATOR_VERSION
RUN \
    apk add --no-cache \
        git \
        openssh-client \
        py3-pip \
        python3 \
    && pip3 install \
        --no-cache-dir \
        --prefer-binary \
        --find-links "https://wheels.home-assistant.io/musllinux/${BUILD_ARCH}/" \
        hass-configurator=="${CONFIGURATOR_VERSION}" \
    \
    && find /usr/local \
        \( -type d -a -name test -o -name tests -o -name '__pycache__' \) \
        -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
        -exec rm -rf '{}' +

# Copy data
COPY rootfs /
