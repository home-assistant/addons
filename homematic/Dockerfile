ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libusb-1.0 \
        lighttpd \
        nginx \
        openjdk-11-jre-headless \
    && rm -rf /var/lib/apt/lists/*

ARG OCCU_VERSION
ARG CCU_VERSION
ARG BUILD_ARCH

# Install OCCU
WORKDIR /usr/src
RUN curl -SL https://github.com/jens-maus/occu/archive/${OCCU_VERSION}.tar.gz | tar xzf - \
    && cd occu-${OCCU_VERSION} \
    && mkdir -p \
        /boot \
        /opt/hm \
        /opt/hm/etc/config \
        /opt/HmIP \
        /opt/HMServer \
        /var/status \
    \
    && echo "VERSION=${CCU_VERSION}" > /boot/VERSION \
    && cp /boot/VERSION /VERSION \
    && ln -s /opt/hm/etc/config /etc/config \
    \
    && if [ "${BUILD_ARCH}" = "armv7" ]; \
        then \
            cd arm-gnueabihf-gcc8; \
        else \
            cd X86_32_GCC8; \
        fi \
    \
    && cp -R packages-eQ-3/RFD/bin /opt/hm/ \
    && cp -R packages-eQ-3/RFD/lib /opt/hm/ \
    && cp -R packages-eQ-3/LinuxBasis/bin /opt/hm/ \
    && cp -R packages-eQ-3/LinuxBasis/lib /opt/hm/ \
    && cp -R packages-eQ-3/HS485D/bin /opt/hm/ \
    && cp -R packages-eQ-3/HS485D/lib /opt/hm/ \
    \
    && cp -R packages-eQ-3/WebUI/bin /opt/hm/ \
    && cp -R packages-eQ-3/WebUI/lib /opt/hm/ \
    && rm -rf packages-eQ-3/WebUI/etc/config* packages-eQ-3/WebUI/ect/rega.conf \
    && mv /opt/hm/bin/ReGaHss.normal /opt/hm/bin/ReGaHss \
    && rm -f /opt/hm/bin/ReGaHss.* \
    && cp -R packages-eQ-3/WebUI/etc/* /opt/hm/etc/ \
    && cp -R packages/lighttpd/etc/lighttpd /opt/hm/etc/ \
    && sed -i "s|/etc/lighttpd/||" /opt/hm/etc/lighttpd/conf.d/proxy.conf \
    \
    && cd ../ \
    && cp -r firmware / \
    && cp -R HMserver/opt/HmIP/* /opt/HmIP/ \
    && cp -a HMserver/opt/HMServer/*.jar /opt/HMServer/ \
    && cp -R HMserver/opt/HMServer/groups /opt/HMServer/ \
    && cp -R HMserver/opt/HMServer/measurement /opt/HMServer/ \
    && cp -R HMserver/opt/HMServer/pages /opt/HMServer/ \
    \
    && sed -i "s/WEBUI_VERSION = \".*\"/WEBUI_VERSION = \"${CCU_VERSION}\"/" WebUI/www/rega/pages/index.htm \
    && cp -R WebUI/* / \
    && ln -s /www /opt/hm/www \
    \
    && touch /opt/hm/etc/config/userAckSecurityHint \
    && touch /opt/hm/etc/config/firewallConfigured \
    && touch /opt/hm/etc/config/legacyAPIMigrationAccepted \
    \
    && rm -rf /usr/src/occu-${OCCU_VERSION}

ENV HM_HOME=/opt/hm LD_LIBRARY_PATH=/opt/hm/lib:${LD_LIBRARY_PATH}

# Update config files
COPY data/config/* /opt/hm/etc/config/
COPY data/nginx.conf /etc/nginx/nginx.conf

# Setup start script
COPY data/run.sh /
COPY data/hm-firmware.sh data/hm-interface.sh /usr/lib/

WORKDIR /data
CMD [ "/run.sh" ]
