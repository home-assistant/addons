ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install deCONZ dependencies
ARG BUILD_ARCH
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        kmod \
        lsof \
        tzdata \
        netcat \
        gnupg-agen \
        software-properties-common \
        libcap2-bin \
        libqt5core5a \
        libqt5gui5 \
        libqt5network5 \
        libqt5serialport5 \
        libqt5sql5 \
        libqt5websockets5 \
        libqt5widgets5 \
        sqlite3 \
    && rm -rf /var/lib/apt/lists/* \
    && if [ "${BUILD_ARCH}" = "armhf" ] || [ "${BUILD_ARCH}" = "aarch64" ]; \
        then \
            curl -q -L -o /wiringpi.deb https://unicorn.drogon.net/wiringpi-2.46-1.deb \
            && dpkg -i /wiringpi.deb \
            && rm -rf /wiringpi.deb; \
        fi

# Install deCONZ
ARG DECONZ_VERSION
RUN curl -fsSL http://phoscon.de/apt/deconz.pub.key | apt-key add - \
    && if [ "${BUILD_ARCH}" = "armhf" ] || [ "${BUILD_ARCH}" = "aarch64" ]; \
        then \
            echo "deb http://phoscon.de/apt/deconz $(lsb_release -cs) main" > /etc/apt/sources.list.d/deconz.list; \
        else \
            echo "deb [arch=amd64] http://phoscon.de/apt/deconz $(lsb_release -cs) main" > /etc/apt/sources.list.d/deconz.list; \
        fi \
    && apt-get update \
    && apt-get install -y --no-install-recommends deconz=${DECONZ_VERSION} \
    && rm -rf /var/lib/apt/lists/* \
    && chown root:root /usr/bin/deCONZ* \
    && sed -i 's/\/root/\/data/' /etc/passwd

COPY data/run.sh data/discovery.sh /
COPY data/ika-otau-dl.sh /bin/

CMD ["/run.sh"]
