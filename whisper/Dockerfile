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
        'onnxruntime==1.28.0' \
        'faster-whisper==1.2.1' \
        'ctranslate2==4.8.1' \
        'sherpa-onnx==1.13.4' \
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

# ONNX Runtime 1.29.0 introduced telemetry on Linux, uploading usage events and
# a persistent device identifier to a Microsoft endpoint by default. The pinned
# 1.28.0 does not have it; keep the opt-out in place for future upgrades.
ENV ORT_DISABLE_TELEMETRY=1
WORKDIR /
COPY rootfs /

HEALTHCHECK --start-period=10m \
    CMD echo '{ "type": "describe" }' \
        | nc -w 1 localhost 10300 \
        | grep -q "faster-whisper" \
        || exit 1
