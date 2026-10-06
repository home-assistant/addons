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
        libqt6gui6 \
        libqt6network6 \
        libqt6serialport6 \
        libqt6sql6 \
        libqt6websockets6 \
        libqt6widgets6 \
        libqt6qml6 \
        libqt6core5compat6 \
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
RUN \
    set -x \
    && if [ "${BUILD_ARCH}" = "aarch64" ]; \
        then \
            curl -q -L -o /deconz.deb \
                "https://github.com/dresden-elektronik/deconz-rest-plugin/releases/download/v${DECONZ_VERSION}/deconz-qt6_${DECONZ_VERSION}_arm64.deb"; \
        else \
            curl -q -L -o /deconz.deb \
                "https://github.com/dresden-elektronik/deconz-rest-plugin/releases/download/v${DECONZ_VERSION}/deconz-qt6_${DECONZ_VERSION}_amd64.deb"; \
        fi \
    && dpkg -i /deconz.deb \
    && rm -f /deconz.deb \
    && chown root:root /usr/bin/deCONZ* \
    && sed -i 's/\/root/\/data/' /etc/passwd

COPY rootfs /

ENV S6_STAGE2_HOOK=/etc/s6-overlay/scripts/enable-check.sh
