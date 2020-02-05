ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Meta
WORKDIR /usr/src
ARG BUILD_ARCH
ARG LIBCEC_VERSION

# Build libcec for HDMI-CEC
COPY data/libcec.patch /usr/src/
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
        linux-headers \
    && git clone --depth 1 -b libcec-${LIBCEC_VERSION} \
        "https://github.com/Pulse-Eight/libcec" /usr/src/libcec \
    && cd /usr/src/libcec \
    && git apply /usr/src/libcec.patch \
    && mkdir -p /usr/src/libcec/build \
    && cd /usr/src/libcec/build \
    && if [[ "armhf armv7 aarch64" = *"$BUILD_ARCH"* ]]; then \
            cmake \
                -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
                -DRPI_INCLUDE_DIR=/opt/vc/include \
                -DRPI_LIB_DIR=/opt/vc/lib \
                -DHAVE_EXYNOS_API=1 \
                -DHAVE_AOCEC_API=1 \
                -DHAVE_LINUX_API=1 \
                ..; \
        else \
            cmake \
                -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
                -DHAVE_LINUX_API=1 \
                ..; \
        fi \
    && make -j$(nproc) \
    && make install \
    && apk del --no-cache .build-dependencies \
    && if [[ "armhf armv7 aarch64" = *"$BUILD_ARCH"* ]]; then \
            apk del --no-cache raspberrypi-dev; \
        fi \
    && rm -rf /usr/src/*

ENV LD_LIBRARY_PATH=/opt/vc/lib:${LD_LIBRARY_PATH}

# Copy data
COPY data/run.sh /

WORKDIR /
CMD [ "/run.sh" ]
