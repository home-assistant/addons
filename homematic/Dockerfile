ARG BUILD_FROM
FROM $BUILD_FROM

# Install packages
RUN apt-get update \
    && apt-get install -y \
        curl \
        libusb-1.0 \
        openjdk-11-jre-headless \
    && rm -rf /var/lib/apt/lists/*

ARG OCCU_VERSION
ARG BUILD_ARCH

# Install OCCU
WORKDIR /usr/src
RUN curl -SL https://github.com/eq-3/occu/archive/${OCCU_VERSION}.tar.gz | tar xzf - \
    && cd occu-${OCCU_VERSION} \
    && mkdir -p /opt/hm \
    && mkdir -p /opt/hm/etc/config \
    && mkdir -p /opt/HmIP \
    && mkdir -p /opt/HMServer \
    && mkdir -p /boot \
    && echo "VERSION=${OCCU_VERSION}" > /boot/VERSION \
    && ln -s /opt/hm/etc/config /etc/config \
    && if [ "${BUILD_ARCH}" = "armhf" ]; \
        then \
            cd arm-gnueabihf; \
        else \
            cd X86_32_Debian_Wheezy; \
        fi \
    && cp -R packages-eQ-3/RFD/bin /opt/hm/ \
    && cp -R packages-eQ-3/RFD/lib /opt/hm/ \
    && cp -R packages-eQ-3/RFD/opt/HmIP/* /opt/HmIP/ \
    && cp -R packages-eQ-3/LinuxBasis/bin /opt/hm/ \
    && cp -R packages-eQ-3/LinuxBasis/lib /opt/hm/ \
    && cp -R packages-eQ-3/HS485D/bin /opt/hm/ \
    && cp -R packages-eQ-3/HS485D/lib /opt/hm/ \
    && cd ../ \
    && cp -r firmware / \
    && mv /firmware/HmIP-RFUSB/hmip_coprocessor_update.eq3 /firmware/HmIP-RFUSB/hmip_coprocessor_update-2.8.6.eq3 \
    && cp -R HMserver/opt/HmIP/* /opt/HmIP/ \
    && cp -a HMserver/opt/HMServer/HMIPServer.jar /opt/HMServer/ \
    && cp -R HMserver/opt/HMServer/groups /opt/HMServer/ \
    && cp -R HMserver/opt/HMServer/measurement /opt/HMServer/ \
    && cp -R HMserver/opt/HMServer/pages /opt/HMServer/ \
    && rm -rf /usr/src/occu-${OCCU_VERSION}
ENV HM_HOME=/opt/hm LD_LIBRARY_PATH=/opt/hm/lib:${LD_LIBRARY_PATH}

# Update config files
COPY rfd.conf hs485d.conf crRFD.conf log4j.xml /etc/config/

# Setup start script
COPY run.sh /
COPY hm-firmware.sh /usr/lib/
RUN chmod a+x /run.sh

WORKDIR /data
CMD [ "/run.sh" ]
