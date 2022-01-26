ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libusb-1.0 \
        lighttpd \
        lighttpd-mod-openssl \
        nginx \
        openjdk-11-jre-headless \
    && rm -rf /var/lib/apt/lists/*

ARG OCCU_VERSION
ARG BUILD_ARCH

# Install OCCU
WORKDIR /usr/src
RUN \
    set -x \
    && curl -SL https://github.com/eq-3/occu/archive/${OCCU_VERSION}.tar.gz | tar xzf - \
    && cd occu-${OCCU_VERSION} \
    && mkdir -p \
        /boot \
        /opt/hm \
        /opt/hm/etc/config \
        /opt/HmIP \
        /opt/HMServer \
        /var/status \
    \
    && echo "VERSION=${OCCU_VERSION}" > /boot/VERSION \
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
    && rm -rf packages-eQ-3/WebUI/etc/config* packages-eQ-3/WebUI/etc/rega.conf \
    && mv /opt/hm/bin/ReGaHss.normal /opt/hm/bin/ReGaHss \
    && rm -f /opt/hm/bin/ReGaHss.* \
    && cp -R packages-eQ-3/WebUI/etc/* /opt/hm/etc/ \
    && cp -R packages/lighttpd/etc/lighttpd /opt/hm/etc/ \
    && sed -i "s|/etc/lighttpd/||" /opt/hm/etc/lighttpd/conf.d/proxy.conf \
    \
    && cd ../ \
    \
    && cp -r firmware / \
    && mv /firmware/HmIP-RFUSB/hmip_coprocessor_update.eq3 /firmware/HmIP-RFUSB/hmip_coprocessor_update-2.8.6.eq3 \
    && sed -i "s/hmip_coprocessor_update.eq3/hmip_coprocessor_update-2.8.6.eq3/" /firmware/HmIP-RFUSB/fwmap \
    && sed -i "s/2.8.4/2.8.6/" /firmware/HmIP-RFUSB/fwmap \
    \
    && cp -R HMserver/opt/HmIP/* /opt/HmIP/ \
    && cp -a HMserver/opt/HMServer/*.jar /opt/HMServer/ \
    && cp -R HMserver/opt/HMServer/groups /opt/HMServer/ \
    && cp -R HMserver/opt/HMServer/measurement /opt/HMServer/ \
    && cp -R HMserver/opt/HMServer/pages /opt/HMServer/ \
    \
    && sed -i "s/WEBUI_VERSION = \".*\"/WEBUI_VERSION = \"${OCCU_VERSION}\"/" WebUI/www/rega/pages/index.htm \
    && cp -R WebUI/* / \
    && ln -s /www /opt/hm/www \
    \
    && touch /opt/hm/etc/config/userAckSecurityHint \
    && touch /opt/hm/etc/config/firewallConfigured \
    && touch /opt/hm/etc/config/legacyAPIMigrationAccepted \
    \
    && rm -rf /usr/src/occu-${OCCU_VERSION}

ENV \
    HM_HOME=/opt/hm \
    LD_LIBRARY_PATH=/opt/hm/lib:${LD_LIBRARY_PATH}

COPY rootfs /
