ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install Whisper
WORKDIR /usr/src
ARG \
    WYOMING_WHISPER_VERSION \
    WYOMING_VERSION \
    TRANSFORMERS_VERSION \
    ONNX_ASR_VERSION \
    FUNASR_VERSION \
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
        "funasr==${FUNASR_VERSION}" \
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

ENV ORT_DISABLE_TELEMETRY=1
WORKDIR /
COPY rootfs /

HEALTHCHECK --start-period=10m --start-interval=5s --interval=30s \
    CMD echo '{ "type": "describe" }' \
        | nc -w 1 localhost 10300 \
        | grep -q "faster-whisper" \
        || exit 1
