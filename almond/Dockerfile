ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG BUILD_ARCH

# Base env settings
ENV \
    LANG="en_US.utf8" \
    PULSE_SERVER=unix:/run/audio/pulse.sock \
    THINGENGINE_HOME="/data/almond-server" \
    THINGENGINE_HAS_REVERSE_PROXY=true \
    THINGENGINE_HOST_BASED_AUTHENTICATION=insecure \
    THINGENGINE_IN_HOME_ASSISTANT_ADDON=true

ARG GENIE_CLIENT_VERSION
ARG GENIE_SERVER_VERSION

RUN set -x \
    && apt-get update \
    # Install runtime dependencies
    && apt-get install -y --no-install-recommends \
        wget \
        curl \
        gnupg \
        pulseaudio \
        pulseaudio-utils \
        libpulse0 \
        libpulse-mainloop-glib0 \
        libasound2 \
        libjson-glib-1.0-0 \
        libevdev2 \
        libsoup2.4-1 \
        libspeexdsp1 \
        libwebrtc-audio-processing1 \
        sound-theme-freedesktop \
        unzip \
        coreutils \
        ca-certificates \
        zip \
        nginx \
        gstreamer1.0-plugins-base-apps \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-pulseaudio \
    && curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key \
        | apt-key add - \
    && echo "deb https://deb.nodesource.com/node_12.x buster main" \
        > /etc/apt/sources.list.d/nodesource.list \
    \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        nodejs \
    # Install genie-client
    && mkdir /src \
    && apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        ninja-build \
        git \
        meson \
        python-dev \
        gettext \
        libgstreamer1.0-dev \
        libasound2-dev \
        libglib2.0-dev \
        libjson-glib-dev \
        libsoup2.4-dev \
        libevdev-dev \
        libpulse-dev \
        libspeex-dev \
        libspeexdsp-dev \
        libwebrtc-audio-processing-dev \
    && git clone \
        "https://github.com/stanford-oval/genie-client" /src \
    && cd /src \
    && git checkout ${GENIE_CLIENT_VERSION} \
    && git submodule init && git submodule update --recursive \
    && ./scripts/get-assets.sh ${BUILD_ARCH} \
    && meson build \
    && ninja -C build \
    && ninja -C build install \
    && rm -rf /src \
    # Install genie-server
    && mkdir /opt/genie-server \
    && cd /opt/genie-server \
    && apt-get install -y --no-install-recommends \
    && git clone -b ${GENIE_SERVER_VERSION} --depth 1 https://github.com/stanford-oval/genie-server /opt/genie-server \
    && npm config set unsafe-perm \
    && npm ci \
    && apt-get purge -y --auto-remove \
        build-essential \
        pkg-config \
        git \
        ninja-build \
        meson \
        python-dev \
        libpulse-dev \
        libgstreamer1.0-dev \
        libasound2-dev \
        libglib2.0-dev \
        libjson-glib-dev \
        libsoup2.4-dev \
        libevdev-dev \
        libspeex-dev \
        libspeexdsp-dev \
        libwebrtc-audio-processing-dev \
    && rm -rf \
        /opt/genie-server/.[!.]* \
        /root/.cache \
        /root/.config \
        /tmp/.[!.]* \
        /tmp/* \
        /usr/local/share/.cache \
        /usr/local/share/.config \
        /var/lib/apt/lists/* \
        /usr/lib/nginx \
        /var/www

COPY rootfs /
