ARG BUILD_FROM
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install openWakeWord
WORKDIR /usr/src
ARG WYOMING_OPENWAKEWORD_VERSION
ENV PIP_BREAK_SYSTEM_PACKAGES=1

RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        netcat-traditional \
        python3 \
        python3-pip \
    \
    && pip3 install --no-cache-dir -U \
        setuptools \
        wheel \
    && pip3 install --no-cache-dir \
        --extra-index-url https://www.piwheels.org/simple \
        "wyoming[zeroconf]>=1.8,<2" \
        "wyoming-openwakeword @ https://github.com/rhasspy/wyoming-openwakeword/archive/refs/tags/v${WYOMING_OPENWAKEWORD_VERSION}.tar.gz" \
    \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /
COPY rootfs /

HEALTHCHECK --start-period=10m \
    CMD echo '{ "type": "describe" }' \
        | nc -w 1 localhost 10400 \
        | grep -iq "openWakeWord" \
        || exit 1
