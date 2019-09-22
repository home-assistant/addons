ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        libusb-1.0 \
        openjdk-11-jre-headless \
    && rm -rf /var/lib/apt/lists/*

ARG OCCU_VERSION
ARG BUILD_ARCH

# Install OCCU
WORKDIR /usr/src
RUN curl -SL https://github.com/jens-maus/occu/archive/${OCCU_VERSION}.tar.gz | tar xzf - \
    && cd occu-${OCCU_VERSION} \
    && mkdir -p /opt/hm \
    && mkdir -p /opt/hm/etc/config \
    && mkdir -p /opt/HmIP \
    && mkdir -p /opt/HMServer \
    && mkdir -p /var/status \
    && mkdir -p /boot \
    \
    && echo "VERSION=${OCCU_VERSION}" > /boot/VERSION \
    && ln -s /opt/hm/etc/config /etc/config \
    \
    && if [ "${BUILD_ARCH}" = "armv7" ]; \
        then \
            cd arm-gnueabihf; \
        else \
            cd X86_32_Debian_Wheezy; \
        fi \
    \
    && cp -R packages-eQ-3/RFD/bin /opt/hm/ \
    && cp -R packages-eQ-3/RFD/lib /opt/hm/ \
    && cp -R packages-eQ-3/RFD/opt/HmIP/* /opt/HmIP/ \
    && cp -R packages-eQ-3/LinuxBasis/bin /opt/hm/ \
    && cp -R packages-eQ-3/LinuxBasis/lib /opt/hm/ \
    && cp -R packages-eQ-3/HS485D/bin /opt/hm/ \
    && cp -R packages-eQ-3/HS485D/lib /opt/hm/ \
    && rm -f packages-eQ-3/WebUI/bin/ReGa* \
    && cp -R packages-eQ-3/WebUI/bin /opt/hm/ \
    && cp -R packages-eQ-3/WebUI/lib /opt/hm/ \
    && rm -rf packages-eQ-3/WebUI/etc/config* \
    && cp -R packages-eQ-3/WebUI/etc/* /opt/hm/etc/ \
    && cp -R packages-eQ-3/WebUI-Beta/bin /opt/hm/ \
    && cp -R packages/lighttpd/bin /opt/hm/ \
    && cp -R packages/lighttpd/lib /opt/hm/ \
    && cp -R packages/lighttpd/etc/lighttpd /opt/hm/etc/ \
    && cd ../ \
    \
    && cp -r firmware / \
    && cp -R HMserver/opt/HmIP/* /opt/HmIP/ \
    && cp -a HMserver/opt/HMServer/HMIPServer.jar /opt/HMServer/ \
    && cp -R HMserver/opt/HMServer/groups /opt/HMServer/ \
    && cp -R HMserver/opt/HMServer/measurement /opt/HMServer/ \
    && cp -R HMserver/opt/HMServer/pages /opt/HMServer/ \
    && cp -R WebUI / \
    && ln -s /WebUI/www /opt/hm/www \
    && rm -rf /usr/src/occu-${OCCU_VERSION}

ENV HM_HOME=/opt/hm LD_LIBRARY_PATH=/opt/hm/lib:${LD_LIBRARY_PATH}

# Update config files
COPY data/rfd.conf data/hs485d.conf data/crRFD.conf data/log4j.xml /opt/hm/etc/config/

# Setup start script
COPY data/run.sh /
COPY data/hm-firmware.sh /usr/lib/

WORKDIR /data
CMD [ "/run.sh" ]
