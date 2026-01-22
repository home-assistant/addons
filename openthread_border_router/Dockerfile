ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH
ARG OTBR_VERSION
ARG SERIALX_VERSION
ARG UNIVERSAL_SILABS_FLASHER_VERSION

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV BORDER_ROUTING 1
ENV BACKBONE_ROUTER 1
ENV PLATFORM debian
ENV RELEASE 1
ENV WEB_GUI 1
ENV REST_API 1
ENV DHCPV6_PD_REF 0
ENV THREAD_VERSION 1.4
ENV DOCKER 1

COPY 0002-spinel-Clear-source-match-tables-before-restoring.patch /usr/src
COPY openthread-core-ha-config-posix.h /usr/src
# Required and installed (script/bootstrap) can be removed after build
ENV OTBR_BUILD_DEPS build-essential ninja-build cmake wget ca-certificates \
  libreadline-dev libncurses-dev libcpputest-dev libdbus-1-dev libavahi-common-dev \
  libavahi-client-dev libboost-dev libboost-filesystem-dev libboost-system-dev \
  libnetfilter-queue-dev

# Installed during build (script/bootstrap) but unused in our configuration
ENV OTBR_UNUSED_DEBS libavahi-client3 avahi-daemon rsyslog

WORKDIR /usr/src

# Install npm/nodejs for WebUI before calling script/bootstrap to avoid
# systemd getting pulled in
RUN \
    set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       iproute2 \
       python3 \
       python3-pip \
       lsb-release \
       netcat-openbsd \
       socat \
       sudo \
       git \
       nodejs \
       npm \
    && git clone --depth 1 -b main \
       https://github.com/openthread/ot-br-posix.git \
    && cd ot-br-posix \
    && git fetch origin ${OTBR_VERSION} \
    && git checkout FETCH_HEAD \
    && git submodule update --init \
    && ./script/bootstrap \
    && ( \
        cd third_party/openthread/repo \
        && patch -p1 < /usr/src/0002-spinel-Clear-source-match-tables-before-restoring.patch \
        && cp /usr/src/openthread-core-ha-config-posix.h . \
       ) \
    # Mimic rt_tables_install \
    && echo "88 openthread" >> /etc/iproute2/rt_tables \
    # Mimic otbr_install \
    # Note: Using default build options for mDNS configuration: \
    #   - OTBR_MDNS=openthread (native OT mDNS implementation) \
    #   - OTBR_DNSSD_DISCOVERY_PROXY=OFF (handled by native mDNS) \
    #   - OTBR_SRP_ADVERTISING_PROXY=OFF (handled by native mDNS) \
    # This enables CLI commands: ot-ctl srp server service/host, ot-ctl mdns services/hosts \
    && (./script/cmake-build \
        -DBUILD_TESTING=OFF \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DOTBR_FEATURE_FLAGS=ON \
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
        # DNS upstream query is not needed with native OpenThread mDNS module \
        -DOTBR_DNS_UPSTREAM_QUERY=OFF \
        -DOT_CHANNEL_MONITOR=ON \
        -DOT_COAP=OFF \
        -DOT_COAPS=OFF \
        -DOT_DNS_CLIENT_OVER_TCP=OFF \
        -DOT_THREAD_VERSION=${THREAD_VERSION} \
        -DOT_PROJECT_CONFIG="../openthread-core-ha-config-posix.h" \
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
