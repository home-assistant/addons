ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV QT_ASSUME_STDERR_HAS_CONSOLE=1

ARG OZW_VERSION
ARG QTMQTT_VERSION
ARG QTOZW_VERSION
ARG QTOZWADMIN_VERSION
ARG QTWEBSOCKETS_VERSION

# Install QT Open Z-Wave 
WORKDIR /usr/src
RUN \
    apk add --no-cache \
        eudev-libs \
        fontconfig \
        mosquitto \
        mosquitto-clients \
        openssl \
        pwgen \
        qt5-qtbase \
        qt5-qtremoteobjects \
        qt5-qtserialport \
        qt5-qtsvg \
        rapidjson \
        ttf-freefont \
    && apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main \
        libunwind \
        libunwind-dev \
    && apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        novnc \
        websockify \
    && apk add --no-cache --virtual .build-dependencies \
        binutils \
        build-base \
        cmake \
        coreutils \
        curl-dev \
        eudev-dev \
        git \
        openssl-dev \
        qt5-qtbase-dev \
        qt5-qtremoteobjects-dev \
        qt5-qtserialport-dev \
        qt5-qtsvg-dev \
        rapidjson-dev \
    \
    && git clone --depth 1 -b \
        ${QTWEBSOCKETS_VERSION} https://github.com/qt/qtwebsockets /usr/src/qtwebsockets \
    && cd /usr/src/qtwebsockets \
    && /usr/lib/qt5/bin/qmake QT_BUILD_PARTS="libs tools" \
    && make -j $(( $(nproc) + 1 )) \
    && make install \
    \
    && git clone --depth 1 -b \
        ${QTMQTT_VERSION} https://github.com/qt/qtmqtt /usr/src/qtmqtt \
    && cd /usr/src/qtmqtt \
    && /usr/lib/qt5/bin/qmake CONFIG+=release QT_BUILD_PARTS="libs tools" \
    && make -j $(( $(nproc) + 1 )) \
    && make install \
    \
    && git clone \
        https://github.com/OpenZWave/open-zwave /usr/src/ozw \
    && cd /usr/src/ozw \
    && git checkout ${OZW_VERSION} \
    && make -j $(( $(nproc) + 1 )) \
    && make install \
    \
    && git clone \
        https://github.com/OpenZWave/qt-openzwave /usr/src/qtozw \
    && cd /usr/src/qtozw \
    && git checkout ${QTOZW_VERSION} \
    && /usr/lib/qt5/bin/qmake -r CONFIG+=release \
    && make -j $(( $(nproc) + 1 )) \
    && make install \
    \
    && git clone \
        https://github.com/OpenZWave/ozw-admin.git /usr/src/ozw-admin \
    && cd /usr/src/ozw-admin \
    && git checkout ${QTOZWADMIN_VERSION} \
    && /usr/lib/qt5/bin/qmake -r CONFIG+=release \
    && make -j $(( $(nproc) + 1 )) \
    && make install \
    \
    && mkdir -p /usr/share/OpenZWave \
    && mv /usr/share/qt5/qt-openzwavedatabase.rcc /usr/share/OpenZWave/ \
    \
    && apk del --no-cache \
        .build-dependencies \
        libunwind-dev \
    && rm -rf /usr/src/*

WORKDIR /
COPY rootfs /
