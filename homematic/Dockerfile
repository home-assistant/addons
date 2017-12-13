ARG BUILD_FROM
FROM $BUILD_FROM

# Install packages
RUN apk add --no-cache \
    curl \
    libc6-compat libstdc++ libgcc libusb

ARG OCCU_VERSION
ARG BUILD_ARCH

# Install OCCU
WORKDIR /usr/src
RUN curl -L -o occu.tar.gz https://github.com/eq-3/occu/archive/${OCCU_VERSION}.tar.gz \
    && tar xzpf occu.tar.gz \
    && rm -f occu.tar.gz \
    && cd occu-${OCCU_VERSION} \
    && if [ "$BUILD_ARCH" == "armhf" ]; then cd arm-gnueabihf; else cd X86_32_Debian_Wheezy; fi \
    && ./install.sh \
    && ln -s /opt/hm/etc/config /etc/config \
    && cp -r ../firmware /opt/hm/ \
    && rm -rf /usr/src/occu-${OCCU_VERSION}

# Update config files
COPY rfd.conf /etc/config

# Setup start script
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
