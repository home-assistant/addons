ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

WORKDIR /usr/src
ARG BUILD_ARCH

##
# RPi support for HDMI-CEC on armhf/aarch64
RUN if [ "$BUILD_ARCH" == "armhf" ] || [ "$BUILD_ARCH" == "aarch64" ]; then \
        apk add --no-cache raspberrypi-dev raspberrypi-libs; \
    fi

##
# Build libcec for HDMI-CEC
ARG LIBCEC_VERSION
RUN apk add --no-cache eudev-libs p8-platform \
    && apk add --no-cache --virtual .build-dependencies \
        build-base cmake eudev-dev git swig p8-platform-dev \
    && git clone --depth 1 -b libcec-${LIBCEC_VERSION} https://github.com/Pulse-Eight/libcec /usr/src/libcec \
    && mkdir -p /usr/src/libcec/build \
    && cd /usr/src/libcec/build \
    && if [ "$BUILD_ARCH" != "armhf" ] && [ "$BUILD_ARCH" != "aarch64" ]; then \
            cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local ..; \
        else \
            cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
                -DRPI_INCLUDE_DIR=/opt/vc/include \
                -DRPI_LIB_DIR=/opt/vc/lib ..; \
        fi \
    && make -j$(nproc) \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/libcec
ENV LD_LIBRARY_PATH=/opt/vc/lib:${LD_LIBRARY_PATH}

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

WORKDIR /
CMD [ "/run.sh" ]
