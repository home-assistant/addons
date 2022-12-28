ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
   set -x \
   && apt-get update \
   && apt-get install -y --no-install-recommends \
   libuv1 \
   openssl \
   zlib1g \
   libjson-c5 \
   python3-venv \
   python3-pip \
   python3-gi \
   python3-gi-cairo \
   python3-dbus \
   python3-psutil \
   unzip \
   libcairo2 \
   gdb \
   git \
   && git clone --depth 1 -b master \
   https://github.com/project-chip/connectedhomeip \
   && cp -r connectedhomeip/credentials /root/credentials \
   && mv /root/credentials/production/paa-root-certs/* \
   /root/credentials/development/paa-root-certs/ \
   && rm -rf connectedhomeip \
   && apt-get purge -y --auto-remove \
   git \
   && rm -rf /var/lib/apt/lists/* \
   && rm -rf /usr/src/*

WORKDIR /root

ARG MATTER_SERVER_VERSION

# hadolint ignore=DL3013
RUN \
   pip3 install --no-cache-dir "python-matter-server[server]==${MATTER_SERVER_VERSION}"

COPY rootfs /
