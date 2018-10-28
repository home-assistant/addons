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
RUN curl -sL -o occu.tar.gz https://github.com/eq-3/occu/archive/${OCCU_VERSION}.tar.gz \
    && tar xzpf occu.tar.gz \
    && rm -f occu.tar.gz \
    && cd occu-${OCCU_VERSION} \
    && mkdir -p /opt/hm \
    && mkdir -p /opt/HmIP \
    && mkdir -p /opt/HMServer \
    && if [ "${BUILD_ARCH}" = "armhf" ]; \
        then \
            cd arm-gnueabihf; \
        else \
            cd X86_32_Debian_Wheezy; \
        fi \
    && cp -R packages-eQ-3/RFD/bin /opt/hm/ \
    && cp -R packages-eQ-3/RFD/lib /opt/hm/ \
    && cp -R packages-eQ-3/RFD/etc /opt/hm/ \
    && cp -R packages-eQ-3/RFD/opt/HmIP/* /opt/HmIP/ \
    && cp -R packages-eQ-3/LinuxBasis/bin /opt/hm/ \
    && cp -R packages-eQ-3/LinuxBasis/lib /opt/hm/ \
    && cp -R packages-eQ-3/HS485D/bin /opt/hm/ \
    && cp -R packages-eQ-3/HS485D/lib /opt/hm/ \
    && ln -s /opt/hm/etc/config /etc/config \
    && cd ../ \
    && cp -r firmware /opt/hm/ \
    && cp -R HMserver/etc/* /opt/hm/etc/config/ \
    && cp -R HMserver/opt/HmIP/* /opt/HmIP/ \
    && cp -a HMServer/opt/HMServer/HMIPServer.jar /opt/HMServer/ \
    && cp -R HMserver/opt/HMServer/groups /opt/HMServer/ \
	&& cp -R HMserver/opt/HMServer/measurement /opt/HMServer/ \
	&& cp -R HMserver/opt/HMServer/pages /opt/HMServer/ \
    && rm -rf /usr/src/occu-${OCCU_VERSION}
ENV HM_HOME=/opt/hm LD_LIBRARY_PATH=/opt/hm/lib:${LD_LIBRARY_PATH}

# Update config files
COPY rfd.conf hs485d.conf crRFD.conf /etc/config/

# Setup start script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
