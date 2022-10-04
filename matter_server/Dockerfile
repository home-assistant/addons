ARG BUILD_FROM
FROM $BUILD_FROM AS builder-chip

ARG \
    BUILD_ARCH \
    CHIP_VERSION

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY \
    0001-Use-data-as-platform-storage-location.patch \
    0001-Avoid-python_runner.py-deadlock.patch \
    0001-Revert-Python-dependencies.patch \
    /usr/src/

WORKDIR /usr/src

# Install and build CHIP Python Controller
# hadolint ignore=SC1091
RUN \
    set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       gcc g++ \
       git \
       gn \
       libcairo2-dev \
       libdbus-1-dev \
       libgirepository1.0-dev \
       libglib2.0-dev \
       libprotobuf-dev \
       libssl-dev \
       make \
       ninja-build \
       patch \
       pkg-config \
       protobuf-compiler \
       python3-cryptography \
       python3-dbus \
       python3-dev \
       python3-pip \
       python3-venv \
       unzip \
    && git clone --depth 1 -b master \
       https://github.com/project-chip/connectedhomeip \
    && cd connectedhomeip \
    && git fetch origin ${CHIP_VERSION} \
    && git checkout ${CHIP_VERSION} \
    && scripts/checkout_submodules.py --shallow --platform linux \
    && patch -p1 < /usr/src/0001-Use-data-as-platform-storage-location.patch \
    && patch -p1 < /usr/src/0001-Revert-Python-dependencies.patch \
    && ( \
           cd third_party/pigweed/repo/ \
           && patch -p1 < /usr/src/0001-Avoid-python_runner.py-deadlock.patch \
       ) \
    && source scripts/activate.sh scripts/environment_no_cipd.json \
    && scripts/build_python.sh -m minimal

FROM $BUILD_FROM

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
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/src/*

WORKDIR /root

COPY --from=builder-chip /usr/src/connectedhomeip/credentials /root/credentials
COPY --from=builder-chip \
     /usr/src/connectedhomeip/out/python_lib/controller/python/chip_clusters-0.0-py3-none-any.whl \
     /tmp
COPY --from=builder-chip \
     /usr/src/connectedhomeip/out/python_lib/controller/python/chip_core-0.0-cp37-abi3-linux_*.whl \
     /tmp

ARG MATTER_SERVER_VERSION

# hadolint ignore=DL3013
RUN \
    pip3 install --no-cache-dir /tmp/chip_clusters-0.0-py3-none-any.whl \
    && pip3 install --no-cache-dir /tmp/chip_core-0.0-cp37-abi3-linux_*.whl \
    && pip3 install --no-cache-dir python-matter-server=="${MATTER_SERVER_VERSION}" \
    && rm /tmp/*.whl

COPY rootfs /
