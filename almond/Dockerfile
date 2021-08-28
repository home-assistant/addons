ARG BUILD_FROM
FROM ${BUILD_FROM}

# Base env settings
ENV \
    LANG="en_US.utf8" \
    THINGENGINE_HOME="/data/almond-server" \
    THINGENGINE_HAS_REVERSE_PROXY=true \
    THINGENGINE_HOST_BASED_AUTHENTICATION=insecure \
    THINGENGINE_IN_HOME_ASSISTANT_ADDON=true

WORKDIR /opt/almond
ARG ALMOND_VERSION

RUN \
    set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libcanberra-dev \
        libcanberra0 \
        libpulse-dev \
        libatlas-base-dev \
        libatlas3-base \
        pkg-config \
        ca-certificates \
        git \
        gnupg \
        nginx \
        python-dev \
        software-properties-common \
        unzip \
        sqlite \
        coreutils \
        pulseaudio \
        pulseaudio-utils \
        gettext \
        zip \
        wget \
        gstreamer1.0-plugins-base-apps \
        gstreamer1.0-plugins-good \
        gstreamer1.0-pulseaudio \
    \
    && curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key \
        | apt-key add - \
    && echo "deb https://deb.nodesource.com/node_12.x buster main" \
        > /etc/apt/sources.list.d/nodesource.list \
    \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        nodejs \
    \
    && npm config set unsafe-perm \
    \
    && git clone -b "${ALMOND_VERSION}" --depth 1 https://github.com/stanford-oval/almond-server . \
    && npm ci \
    && npm install --no-package-lock --ignore-scripts snowboy@1.3.1 \
    && cd node_modules/snowboy/ \
    && PYTHON=python2 npx node-pre-gyp clean configure \
    && make -C build/ \
    && rm -fr /root/.cache \
    && rm -fr /root/.npm \
    && mkdir /root/.cache \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
        libcanberra-dev \
        libpulse-dev \
        libatlas-base-dev \
        pkg-config \
        git \
        gnupg \
        python-dev \
        software-properties-common \
    \
    && rm -rf \
        /opt/almond/.[!.]* \
        /root/.cache \
        /root/.config \
        /tmp/.[!.]* \
        /tmp/* \
        /usr/local/share/.cache \
        /usr/local/share/.config \
        /usr/lib/nginx \
        /var/lib/apt/lists/* \
        /var/www

COPY rootfs /
