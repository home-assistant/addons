ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install Whisper
WORKDIR /usr/src
ARG \
    WYOMING_WHISPER_VERSION \
    WYOMING_VERSION \
    UV_VERSION \
    TRANSFORMERS_VERSION \
    ONNX_ASR_VERSION \
    FUNASR_VERSION \
    ONNXRUNTIME_VERSION \
    FASTER_WHISPER_VERSION \
    CTRANSLATE2_VERSION \
    SHERPA_ONNX_VERSION \
    TORCH_VERSION \
    AIOHTTP_VERSION \
    TOKENIZERS_VERSION

# The "packs" service reads these at startup: the versions to pin what it
# installs, and the release the uv cache belongs to.
ENV WYOMING_WHISPER_VERSION=${WYOMING_WHISPER_VERSION} \
    TRANSFORMERS_VERSION=${TRANSFORMERS_VERSION} \
    FUNASR_VERSION=${FUNASR_VERSION} \
    TORCH_VERSION=${TORCH_VERSION}

# A unique approach is taken in this image to dependency management. The
# transformers and FunASR backends both need PyTorch, and together they are
# ~1.5 GB out of a ~2 GB install -- for backends that only some configurations
# ever select. Rather than making everyone pay the disk space for them, a
# "packs" s6 dependency installs them on startup when the configuration
# selects one.
#
# Importantly, the uv cache is stored in /data and because uv caches wheels
# uncompressed already, the relevant files can be symlinked into the container's
# filesystem with virtually no overhead. This only works if we target the system
# Python because the build time and runtime dependencies need to be layered.
# Hence, there is no virtual environment anymore.
ENV UV_SYSTEM_PYTHON=true

RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libgomp1 \
        python3 \
        python3-dev \
        python3-pip \
    \
    # Install into the system interpreter rather than a venv
    && rm -f /usr/lib/python3*/EXTERNALLY-MANAGED \
    # pip is only here to bootstrap uv
    && pip3 install --no-cache-dir "uv==${UV_VERSION}" \
    \
    # --no-cache: the runtime cache lives in /data and must not be seeded with
    # build-time downloads baked into the image.
    #
    # torch, torchaudio, transformers and funasr are deliberately absent -- the
    # "packs" service installs those. Everything here is either required by
    # faster-whisper (the fallback backend, always reachable) or small enough
    # not to be worth deferring: sherpa-onnx is ~37 MB and onnx-asr ~0.1 MB,
    # and qwen3-asr needs only onnxruntime and tokenizers, which faster-whisper
    # already pulls in.
    && uv pip install --no-cache \
        "wyoming[zeroconf]==${WYOMING_VERSION}" \
        "wyoming-faster-whisper[sherpa,hass,qwen3-asr] @ https://github.com/rhasspy/wyoming-faster-whisper/archive/refs/tags/v${WYOMING_WHISPER_VERSION}.tar.gz" \
        "onnx-asr[cpu,hub]==${ONNX_ASR_VERSION}" \
        "onnxruntime==${ONNXRUNTIME_VERSION}" \
        "faster-whisper==${FASTER_WHISPER_VERSION}" \
        "ctranslate2==${CTRANSLATE2_VERSION}" \
        "sherpa-onnx==${SHERPA_ONNX_VERSION}" \
        "aiohttp==${AIOHTTP_VERSION}" \
        "tokenizers==${TOKENIZERS_VERSION}" \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

ENV ORT_DISABLE_TELEMETRY=1

# Keep every cache on the /data volume instead of the container's filesystem,
# which is thrown away whenever the app is updated or rebuilt. Model files
# already go there via --download-dir, but the libraries also write caches that
# no command-line option reaches: the Xet chunk cache used during Hugging Face
# downloads is $HF_HOME/xet and can run to several GB, FunASR's models go to
# $MODELSCOPE_CACHE, and the rest falls back to $XDG_CACHE_HOME.
#
# These have to be environment variables: huggingface_hub reads them into
# constants at import time, so setting them from Python would be too late.
ENV HF_HOME=/data \
    XDG_CACHE_HOME=/data \
    MODELSCOPE_CACHE=/data/modelscope

WORKDIR /
COPY rootfs /

# A Describe/Info round trip rather than a bare port check: the port is bound by
# the OS, so a connect-only check stays green even when the event loop is
# wedged. --retries covers the other direction, since transcription runs on that
# same event loop and a check can time out behind a long request.
HEALTHCHECK --start-period=10m --start-interval=5s --interval=30s \
    --timeout=20s --retries=3 \
    CMD ["/usr/bin/python3", "-m", "wyoming_faster_whisper.health_check"]
