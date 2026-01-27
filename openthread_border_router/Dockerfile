ARG BUILD_FROM

# OTBR builder stage
FROM ${BUILD_FROM} AS otbr-builder
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG OTBR_VERSION

ENV BORDER_ROUTING=1
ENV BACKBONE_ROUTER=1
ENV PLATFORM=debian
ENV RELEASE=1
ENV WEB_GUI=1
ENV REST_API=1
ENV DOCKER=1


COPY openthread-core-ha-config-posix.h /usr/src/

WORKDIR /usr/src
RUN \
    set -x \
    && apt-get update \
    # The OTBR build script tries to run `sudo`
    && apt-get install -y --no-install-recommends sudo git \
    && git clone --depth 1 -b main https://github.com/openthread/ot-br-posix.git /usr/src/ot-br-posix \
    && cd /usr/src/ot-br-posix \
    && git fetch origin ${OTBR_VERSION} \
    && git checkout ${OTBR_VERSION} \
    && git submodule update --init \
    # Bootstrap downloads a few more repos
    && ./script/bootstrap

WORKDIR /usr/src/ot-br-posix
RUN \
    set -x \
    && mv /usr/src/openthread-core-ha-config-posix.h /usr/src/ot-br-posix/third_party/openthread/repo/ \
    && ./script/cmake-build \
        -DBUILD_TESTING=OFF \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DOTBR_FEATURE_FLAGS=ON \
        -DOTBR_MDNS=openthread \
        -DOTBR_VERSION= \
        -DOT_PACKAGE_VERSION= \
        -DOTBR_DBUS=OFF \
        -DOT_POSIX_RCP_HDLC_BUS=ON \
        -DOTBR_VENDOR_NAME="Home Assistant" \
        -DOTBR_PRODUCT_NAME="OpenThread Border Router" \
        # The Meshcop service name is specified in `openthread-core-ha-config-posix.h`
        -DOTBR_WEB=ON \
        -DOTBR_BORDER_ROUTING=ON \
        -DOTBR_REST=ON \
        -DOTBR_BACKBONE_ROUTER=ON \
        -DOTBR_TREL=ON \
        -DOTBR_NAT64=ON \
        -DOT_POSIX_NAT64_CIDR="192.168.255.0/24" \
        -DOTBR_DNS_UPSTREAM_QUERY=ON \
        -DOT_CHANNEL_MONITOR=ON \
        -DOT_COAP=OFF \
        -DOT_COAPS=OFF \
        -DOT_THREAD_VERSION=1.4 \
        -DOT_PROJECT_CONFIG="/usr/src/ot-br-posix/third_party/openthread/repo/openthread-core-ha-config-posix.h" \
    && cd /usr/src/ot-br-posix/build/otbr \
    && DESTDIR=/opt/otbr-install ninja install

# Runtime image
FROM ${BUILD_FROM}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG SERIALX_VERSION
ARG UNIVERSAL_SILABS_FLASHER_VERSION

# Install runtime dependencies
RUN \
    set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       python3 \
       python3-pip \
       netcat-openbsd \
       socat \
       iproute2 \
       iputils-ping \
       ipset \
       iptables \
       libreadline8 \
       libncurses6 \
       libprotobuf-lite32 \
       libjsoncpp26 \
    && pip install --break-system-packages --no-cache-dir \
       universal-silabs-flasher==${UNIVERSAL_SILABS_FLASHER_VERSION} \
       serialx==${SERIALX_VERSION} \
    && rm -rf /var/lib/apt/lists/*

# Setup routing table for OpenThread
RUN \
    mkdir -p /etc/iproute2 \
    && echo "88 openthread" >> /etc/iproute2/rt_tables


COPY --from=otbr-builder /opt/otbr-install/usr /usr
COPY rootfs /

ENV \
    S6_STAGE2_HOOK=/etc/s6-overlay/scripts/enable-check.sh
