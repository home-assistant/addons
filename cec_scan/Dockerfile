ARG BUILD_FROM
FROM $BUILD_FROM

WORKDIR /usr/src
ARG BUILD_ARCH

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Build libcec for HDMI-CEC
ARG LIBCEC_VERSION
RUN \
    if [[ "armhf armv7 aarch64" = *"$BUILD_ARCH"* ]]; then \
        apk add --no-cache raspberrypi-dev raspberrypi-libs; \
    fi \
    && apk add --no-cache \
        eudev-libs\
        p8-platform \
    && apk add --no-cache --virtual .build-dependencies \
        build-base \
        cmake \
        eudev-dev \
        git \
        p8-platform-dev \
        swig \
    && git clone --depth 1 -b libcec-${LIBCEC_VERSION} \
        "https://github.com/Pulse-Eight/libcec" /usr/src/libcec \
    && mkdir -p /usr/src/libcec/build \
    && cd /usr/src/libcec/build \
    && if [[ "armhf armv7 aarch64" = *"$BUILD_ARCH"* ]]; then \
            cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local ..; \
        else \
            cmake \
                -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
                -DRPI_INCLUDE_DIR=/opt/vc/include \
                -DRPI_LIB_DIR=/opt/vc/lib ..; \
        fi \
    && make -j$(nproc) \
    && make install \
    && apk del --no-cache .build-dependencies \
    && if [[ "armhf armv7 aarch64" = *"$BUILD_ARCH"* ]]; then \
        apk del --no-cache raspberrypi-dev; \
    fi

ENV LD_LIBRARY_PATH=/opt/vc/lib:${LD_LIBRARY_PATH}

# Copy data
COPY run.sh /

WORKDIR /
CMD [ "/run.sh" ]
