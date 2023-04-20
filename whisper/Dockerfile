ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install Whisper
WORKDIR /usr/src
ARG WHISPER_VERSION

RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        netcat \
        python3 \
        python3-dev \
        python3-pip \
    \
    && pip3 install --no-cache-dir -U \
        setuptools \
        wheel \
    && pip3 install --no-cache-dir \
        "wyoming-faster-whisper==${WHISPER_VERSION}" \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /
COPY rootfs /

HEALTHCHECK --start-period=10m \
    CMD echo '{ "type": "describe" }' \
        | nc -w 1 localhost 10300 \
        | grep -q "faster-whisper" \
        || exit 1
