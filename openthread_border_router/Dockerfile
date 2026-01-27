ARG BUILD_FROM
ARG BUILD_ARCH

# Then build the main image
FROM ${BUILD_FROM}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG OTBR_VERSION
ARG SERIALX_VERSION
ARG UNIVERSAL_SILABS_FLASHER_VERSION

ENV BORDER_ROUTING 1
ENV BACKBONE_ROUTER 1
ENV PLATFORM debian
ENV RELEASE 1
ENV WEB_GUI 1
ENV REST_API 1
ENV OTBR_DHCP6_PD_CLIENT none
ENV DOCKER 1


# Required and installed (script/bootstrap) can be removed after build
ENV OTBR_BUILD_DEPS build-essential ninja-build cmake wget ca-certificates \
  libreadline-dev libncurses-dev libcpputest-dev libdbus-1-dev libavahi-common-dev \
  libavahi-client-dev libboost-dev libboost-filesystem-dev libboost-system-dev \
  libnetfilter-queue-dev

# Installed during build (script/bootstrap) but unused in our configuration
ENV OTBR_UNUSED_DEBS libavahi-client3 avahi-daemon rsyslog
WORKDIR /usr/src

RUN \
    set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends git \
    && git clone --depth 1 -b main \
       https://github.com/openthread/ot-br-posix.git /usr/src/ot-br-posix \
    && cd /usr/src/ot-br-posix \
    && git fetch origin ${OTBR_VERSION} \
    && git checkout ${OTBR_VERSION} \
    && git submodule update --init \
    && rm -rf /var/lib/apt/lists/*


RUN \
    set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       python3 \
       python3-pip \
       lsb-release \
       netcat-openbsd \
       socat \
       sudo \
       # Install npm/nodejs for WebUI before calling script/bootstrap to avoid systemd getting pulled in
       nodejs \
       npm \
       # OpenThread will install these during bootstrapping
       libc-bin libc-dev-bin libc6 libc6-dev libcrypt-dev libncurses6 linux-libc-dev rpcsvc-proto \
       wget iproute2 iputils-ping libreadline-dev libncurses-dev \
       googletest libgmock-dev libgtest-dev \
       build-essential ninja-build cmake \
       dbus libdbus-1-dev \
       rsyslog

COPY openthread-core-ha-config-posix.h /usr/src/ot-br-posix/third_party/openthread/repo

RUN \
    set -x \
    && cd /usr/src/ot-br-posix \
    && ./script/bootstrap

RUN \
    set -x \
    && cd /usr/src/ot-br-posix \
    # Mimic rt_tables_install
    && mkdir /etc/iproute2 \
    && echo "88 openthread" >> /etc/iproute2/rt_tables \
    # Mimic otbr_install
    && (./script/cmake-build \
        -DBUILD_TESTING=OFF \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DOTBR_FEATURE_FLAGS=ON \
        # Use OT core mDNS (handles advertising proxy and discovery proxy internally)
        -DOTBR_MDNS=openthread \
        # Force re-evaluation of version strings
        -DOTBR_VERSION= \
        -DOT_PACKAGE_VERSION= \
        -DOTBR_DBUS=OFF \
        -DOT_POSIX_RCP_BUS_UART=ON \
        -DOT_LINK_RAW=1 \
        -DOTBR_VENDOR_NAME="Home Assistant" \
        -DOTBR_PRODUCT_NAME="OpenThread Border Router" \
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
        -DOT_RCP_RESTORATION_MAX_COUNT=2 \
        && cd build/otbr/ \
        && ninja \
        && ninja install) \
    && pip install --break-system-packages \
       universal-silabs-flasher==${UNIVERSAL_SILABS_FLASHER_VERSION} \
       serialx==${SERIALX_VERSION} \
    && apt-get purge -y --auto-remove \
       git \
       nodejs \
       npm \
       ${OTBR_BUILD_DEPS} \
       ${OTBR_UNUSED_DEBS} \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/src/*

COPY rootfs /

ENV \
    S6_STAGE2_HOOK=/etc/s6-overlay/scripts/enable-check.sh
