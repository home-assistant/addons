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
        openbox \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install deCONZ
ARG DECONZ_VERSION
RUN \
    set -x \
    && if [ "${BUILD_ARCH}" = "armhf" ]; \
        then \
            curl -q -L -o /deconz.deb http://deconz.dresden-elektronik.de/raspbian/stable/deconz-${DECONZ_VERSION}-qt5.deb; \
        elif [ "${BUILD_ARCH}" = "aarch64" ]; \
        then \
            curl -q -L -o /deconz.deb http://deconz.dresden-elektronik.de/debian/stable/deconz_${DECONZ_VERSION}-debian-buster-stable_arm64.deb; \
        else \
            curl -q -L -o /deconz.deb http://deconz.dresden-elektronik.de/ubuntu/stable/deconz-${DECONZ_VERSION}-qt5.deb; \
        fi \
    && dpkg -i /deconz.deb \
    && rm -f /deconz.deb \
    && chown root:root /usr/bin/deCONZ* \
    && sed -i 's/\/root/\/data/' /etc/passwd

COPY rootfs /
