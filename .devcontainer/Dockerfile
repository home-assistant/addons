FROM debian

WORKDIR /workspaces

# Default ENV
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install docker
# https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/
RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common \
        gnupg \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository "deb https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
    && apt-get update && apt-get install -y --no-install-recommends \
        docker-ce \
        docker-ce-cli \
        containerd.io \
    && rm -rf /var/lib/apt/lists/*

# Install tools
ARG SHELLCHECK_VERSION=0.7.0
RUN apt-get update && apt-get install -y --no-install-recommends \
        jq \
        dbus \
        network-manager \
        libpulse0 \
        git \
        tar \
        xz-utils \
    && rm -rf /var/lib/apt/lists/* \
    \
    && curl -SL "https://storage.googleapis.com/shellcheck/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz" | tar xJf - \
    && cp "shellcheck-v${SHELLCHECK_VERSION}/shellcheck" /usr/bin/ \
    && rm -rf shellcheck-v${SHELLCHECK_VERSION}

# Generate a machine-id for this container
RUN rm /etc/machine-id && dbus-uuidgen --ensure=/etc/machine-id

ENV DEBIAN_FRONTEND=dialog