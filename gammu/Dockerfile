ARG BUILD_FROM
FROM ${BUILD_FROM}

# Set environment variables for UTF-8 support
ENV LANG C.UTF-8

# Install system dependencies and Python tooling
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    libgammu-dev \
  && pip3 install --no-cache-dir -U \
    setuptools \
    wheel \
  && pip3 install --no-cache-dir \
    py-smsgateway-async \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Copy root filesystem
COPY rootfs /

