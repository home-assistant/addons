ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install Whisper
WORKDIR /usr/src
ARG WYOMING_WHISPER_VERSION

RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libgomp1 \
        netcat-traditional \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
    \
    && python3 -m venv .venv \
    && .venv/bin/pip3 install --no-cache-dir -U \
        setuptools \
        wheel \
    && .venv/bin/pip3 install --no-cache-dir \
        "wyoming[zeroconf]==1.9.0" \
        "wyoming-faster-whisper[sherpa] @ https://github.com/rhasspy/wyoming-faster-whisper/archive/refs/tags/v${WYOMING_WHISPER_VERSION}.tar.gz" \
        'transformers==4.52.4' \
        'onnx-asr[cpu,hub]==0.11.0' \
        'funasr>=1.1.0,<2' \
    \
    && .venv/bin/pip3 install --no-cache-dir \
        --index-url 'https://download.pytorch.org/whl/cpu' \
        'torch==2.7.1' \
        'torchaudio==2.7.1' \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/src/.venv/bin:$PATH"
WORKDIR /
COPY rootfs /

HEALTHCHECK --start-period=10m \
    CMD echo '{ "type": "describe" }' \
        | nc -w 1 localhost 10300 \
        | grep -q "faster-whisper" \
        || exit 1
