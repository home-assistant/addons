ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install Whisper
WORKDIR /usr/src
ARG \
    WYOMING_WHISPER_VERSION \
    WYOMING_VERSION \
    TRANSFORMERS_VERSION \
    ONNX_ASR_VERSION \
    ONNXRUNTIME_VERSION \
    FASTER_WHISPER_VERSION \
    CTRANSLATE2_VERSION \
    SHERPA_ONNX_VERSION \
    TORCH_VERSION

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
        "wyoming[zeroconf]==${WYOMING_VERSION}" \
        "wyoming-faster-whisper[sherpa] @ https://github.com/rhasspy/wyoming-faster-whisper/archive/refs/tags/v${WYOMING_WHISPER_VERSION}.tar.gz" \
        "transformers==${TRANSFORMERS_VERSION}" \
        "onnx-asr[cpu,hub]==${ONNX_ASR_VERSION}" \
        'funasr>=1.1.0,<2' \
        "onnxruntime==${ONNXRUNTIME_VERSION}" \
        "faster-whisper==${FASTER_WHISPER_VERSION}" \
        "ctranslate2==${CTRANSLATE2_VERSION}" \
        "sherpa-onnx==${SHERPA_ONNX_VERSION}" \
    \
    && .venv/bin/pip3 install --no-cache-dir \
        --index-url 'https://download.pytorch.org/whl/cpu' \
        "torch==${TORCH_VERSION}" \
        "torchaudio==${TORCH_VERSION}" \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/src/.venv/bin:$PATH"

# ONNX Runtime 1.29.0 introduced telemetry on Linux, uploading usage events and
# a persistent device identifier to a Microsoft endpoint by default. Opt out.
ENV ORT_DISABLE_TELEMETRY=1
WORKDIR /
COPY rootfs /

HEALTHCHECK --start-period=10m \
    CMD echo '{ "type": "describe" }' \
        | nc -w 1 localhost 10300 \
        | grep -q "faster-whisper" \
        || exit 1
