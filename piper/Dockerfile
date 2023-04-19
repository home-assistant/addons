ARG BUILD_FROM
FROM ${BUILD_FROM}
ARG BUILD_ARCH

# Install Whisper
WORKDIR /usr/src
ARG PIPER_LIB_VERSION
ARG PIPER_RELEASE

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        wget \
    \
    && pip3 install --no-cache-dir -U setuptools wheel \
    && pip3 install --no-cache-dir "wyoming-piper==${PIPER_LIB_VERSION}" \
    && rm -rf /var/lib/apt/lists/* \
    \
    && if [ "${BUILD_ARCH}" = 'aarch64' ]; then \
    export PIPER_ARCH='arm64'; \
    else export PIPER_ARCH="${BUILD_ARCH}"; \
    fi \
    && wget -O- "https://github.com/rhasspy/piper/releases/download/${PIPER_RELEASE}/piper_${PIPER_ARCH}.tar.gz" | \
    tar -C /usr/share -xzf -

WORKDIR /
COPY rootfs /
