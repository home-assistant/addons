ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH
ARG DECONZ_VERSION

# Install deCONZ dependencies
RUN apt-get update \
    && apt-get install -y \
        curl \
        kmod \
        lsof \
        tzdata \
        libcap2-bin \
        libqt5core5a \
        libqt5gui5 \
        libqt5network5 \
        libqt5serialport5 \
        libqt5sql5 \
        libqt5websockets5 \
        libqt5widgets5 \
        sqlite3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && if [ "${BUILD_ARCH}" = "armhf" ] || [ "${BUILD_ARCH}" = "aarch64" ]; \
        then \
            curl -q -L -o /wiringpi.deb https://unicorn.drogon.net/wiringpi-2.46-1.deb \
            && dpkg -i /wiringpi.deb \
            && rm -rf /wiringpi.deb; \
        fi

# Install deCONZ
RUN if [ "${BUILD_ARCH}" = "armhf" ] || [ "${BUILD_ARCH}" = "aarch64" ]; \
        then \
            curl -q -L -o /deconz.deb https://www.dresden-elektronik.de/rpi/deconz/beta/deconz-${DECONZ_VERSION}-qt5.deb; \
        else \
            curl -q -L -o /deconz.deb https://www.dresden-elektronik.de/deconz/ubuntu/beta/deconz-${DECONZ_VERSION}-qt5.deb; \
        fi \
    && dpkg -i /deconz.deb \
    && rm -f /deconz.deb \
    && chown root:root /usr/bin/deCONZ* \
    && sed -i 's/\/root/\/data/' /etc/passwd

COPY run.sh /
COPY ika-otau-dl.sh /bin/

CMD ["/run.sh"]
