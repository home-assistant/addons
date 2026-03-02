ARG BUILD_FROM
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /usr/src
ARG LINUX_VOICE_ASSISTANT_VERSION
ENV PIP_BREAK_SYSTEM_PACKAGES=1

# Install system dependencies
# Mirrors the packages from the upstream linux-voice-assistant Dockerfile:
# - avahi-utils:        For zeroconf/mDNS discovery by Home Assistant
# - pulseaudio-utils:   Required by soundcard library for audio I/O
# - alsa-utils:         ALSA tools for audio device management
# - pipewire-*:         Required for PipeWire support (modern Linux audio stack)
# - build-essential:    Required to compile pymicro-features C extension
# - libmpv-dev:         Required by python-mpv for audio playback
# - libasound2-plugins: Required by python-mpv for audio playback
# - ca-certificates:    For encrypted connections to Home Assistant
# - procps:             For pgrep in healthcheck
RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        avahi-utils \
        pulseaudio-utils \
        alsa-utils \
        pipewire-bin \
        pipewire-alsa \
        pipewire-pulse \
        build-essential \
        libmpv-dev \
        libasound2-plugins \
        ca-certificates \
        procps \
    \
    && pip3 install --no-cache-dir -U \
        setuptools \
        wheel \
    && pip3 install --no-cache-dir \
        "linux-voice-assistant @ https://github.com/OHF-Voice/linux-voice-assistant/archive/refs/tags/v${LINUX_VOICE_ASSISTANT_VERSION}.tar.gz" \
    \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy default sounds
COPY sounds/ ./sounds/

# Copy wake word models
COPY wakewords/ ./wakewords/

WORKDIR /
COPY rootfs /

HEALTHCHECK --start-period=10m \
    CMD pgrep -f linux_voice_assistant || exit 1