ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

ARG BUILD_ARCH

# Build libcec with RPi support for HDMI-CEC on armhf
RUN apk add --no-cache build-base cmake eudev-dev git swig \
    && if [ "$BUILD_ARCH" != "armhf" ]; then exit 0; else \
        apk add --no-cache raspberrypi-dev raspberrypi raspberrypi-libs; fi \
    && git clone --depth 1 -b p8-platform-2.1.0.1 https://github.com/Pulse-Eight/platform /usr/src/platform \
    && mkdir -p /usr/src/platform/build \
    && cd /usr/src/platform/build \
    && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .. \
    && make \
    && make install \
    && cd /usr/src \
    && rm -rf platform \
    && git clone --depth 1 -b libcec-4.0.2 https://github.com/Pulse-Eight/libcec /usr/src/libcec \
    && mkdir -p /usr/src/libcec/build \
    && cd /usr/src/libcec/build \
    && if [ "$BUILD_ARCH" != "armhf" ]; then \
            cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr \
        else cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr \
            -DRPI_INCLUDE_DIR=/opt/vc/include \
            -DRPI_LIB_DIR=/opt/vc/lib; fi \
    && make \
    && make install \
    && cd /usr/src \
    && rm -rf libcec \
    && apk del build-base cmake eudev-dev git swig \
    && if [ "$BUILD_ARCH" != "armhf" ]; then exit 0; else \
        apk del raspberrypi-dev; fi
ENV LD_LIBRARY_PATH=/opt/vc/lib:${LD_LIBRARY_PATH}

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
