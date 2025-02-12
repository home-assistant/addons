ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install deCONZ dependencies
ARG BUILD_ARCH
RUN \
    set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        dwm \
        iproute2 \
        iputils-ping \
        kmod \
        libcap2-bin \
        libqt5core5a \
        libqt5gui5 \
        libqt5network5 \
        libqt5serialport5 \
        libqt5sql5 \
        libqt5websockets5 \
        libqt5widgets5 \
        libqt5qml5 \
        lsof \
        netcat-traditional \
        nginx \
        novnc \
        sqlite3 \
        tigervnc-common \
        tigervnc-standalone-server \
        udev \
        wget \
        xfonts-base \
        xfonts-scalable \
    && rm -rf /var/lib/apt/lists/*

# Install deCONZ
ARG DECONZ_VERSION
ARG RELEASE_CHANNEL
RUN \
    set -x \
    && if [ "${BUILD_ARCH}" = "armhf" ]; \
        then \
            curl -q -L -o /deconz.deb http://deconz.dresden-elektronik.de/raspbian/${RELEASE_CHANNEL}/deconz-${DECONZ_VERSION}-qt5.deb; \
        elif [ "${BUILD_ARCH}" = "aarch64" ]; \
        then \
            curl -q -L -o /deconz.deb http://deconz.dresden-elektronik.de/debian/${RELEASE_CHANNEL}/deconz_${DECONZ_VERSION}-debian-buster-${RELEASE_CHANNEL}_arm64.deb; \
        else \
            curl -q -L -o /deconz.deb http://deconz.dresden-elektronik.de/ubuntu/${RELEASE_CHANNEL}/deconz-${DECONZ_VERSION}-qt5.deb; \
        fi \
    && dpkg -i /deconz.deb \
    && rm -f /deconz.deb \
    && chown root:root /usr/bin/deCONZ* \
    && sed -i 's/\/root/\/data/' /etc/passwd

COPY rootfs /
