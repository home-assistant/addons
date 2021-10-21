ARG BUILD_FROM
FROM $BUILD_FROM

# Meta
ARG BUILD_ARCH
ARG LIBCEC_VERSION

# Build libcec for HDMI-CEC
WORKDIR /usr/src
RUN \
    apk add --no-cache \
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
    && cmake \
        -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
        -DHAVE_LINUX_API=1 \
        .. \
    && make -j$(nproc) \
    && make install \
    && apk del --no-cache .build-dependencies \
    && rm -rf /usr/src/*

# Copy data
COPY data/run.sh /

WORKDIR /
