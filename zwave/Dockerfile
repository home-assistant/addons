ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install Ada
WORKDIR /usr/src
ARG OZW_VERSION
ARG QTOZW_VERSION
ARG QTMQTT_VERSION
ARG QTWEBSOCKETS_VERSION

RUN \
    apk add --no-cache \
        eudev-libs \
        qt5-qtbase \
        qt5-qtremoteobjects \
        openssl \
        coreutils \
        rapidjson \
        mosquitto \
        libcurl \
        pwgen \
    && apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main \
        libunwind \
        libunwind-dev \
    && apk add --no-cache --virtual .build-dependencies \
        build-base \
        cmake \
        eudev-dev \
        git \
        qt5-qtbase-dev \
        qt5-qtremoteobjects-dev \
        openssl-dev \
        rapidjson-dev \
        curl-dev \
    \
    && git clone --depth 1 -b \
        ${QTWEBSOCKETS_VERSION} https://github.com/qt/qtwebsockets /usr/src/qtwebsockets \
    && cd /usr/src/qtwebsockets \
    && /usr/lib/qt5/bin/qmake QT_BUILD_PARTS="libs tools" \
    && make \
    && make install \
    \
    && git clone --depth 1 -b \
        ${QTMQTT_VERSION} https://github.com/qt/qtmqtt /usr/src/qtmqtt \
    && cd /usr/src/qtmqtt \
    && /usr/lib/qt5/bin/qmake QT_BUILD_PARTS="libs tools" \
    && make \
    && make install \
    \
    && git clone \
        https://github.com/OpenZWave/open-zwave /usr/src/ozw \
    && cd /usr/src/ozw \
    && git checkout ${OZW_VERSION} \
    && make \
    && make install \
    \
    && git clone \
        https://github.com/OpenZWave/qt-openzwave /usr/src/qtozw \
    && cd /usr/src/qtozw \
    && git checkout ${QTOZW_VERSION} \
    && /usr/lib/qt5/bin/qmake \
    && make \
    && make install \
    \
    && apk del --no-cache \
        .build-dependencies \
        libunwind-dev \
    && rm -rf /usr/src/*

WORKDIR /
COPY rootfs /
