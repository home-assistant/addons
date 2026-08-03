ARG BUILD_FROM
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Piper
WORKDIR /usr/src
ARG BUILD_ARCH
ARG WYOMING_PIPER_VERSION
RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        netcat-traditional \
        python3 \
        python3-pip \
        python3-venv \
    \
    && python3 -m venv .venv \
    && .venv/bin/pip3 install --no-cache-dir -U \
        setuptools \
        wheel \
    && .venv/bin/pip3 install --no-cache-dir \
        --extra-index-url https://www.piwheels.org/simple \
        --extra-index-url https://download.pytorch.org/whl/cpu \
        "wyoming-piper[zeroconf,zh] @ https://github.com/rhasspy/wyoming-piper/archive/refs/tags/v${WYOMING_PIPER_VERSION}.tar.gz" \
    \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/src/.venv/bin:$PATH"
WORKDIR /
COPY rootfs /

HEALTHCHECK --start-period=10m \
    CMD echo '{ "type": "describe" }' \
        | nc -w 1 localhost 10200 \
        | grep -q "piper" \
        || exit 1
