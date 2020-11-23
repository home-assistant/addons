FROM mcr.microsoft.com/vscode/devcontainers/base:debian

WORKDIR /workspaces

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set Docker daemon config
RUN \
    mkdir -p /etc/docker \
    && echo '{"storage-driver": "vfs"}' > /etc/docker/daemon.json

# Installa aditional tools
RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        dbus \
        network-manager \
        libpulse0 \
        xz-utils

# Install docker
RUN curl -fsSL https://get.docker.com | sh -

# Install shellcheck
RUN \
    curl -fLs \
        "https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz" \
        | tar -xJ \
    \
    && mv -f "./shellcheck-stable/shellcheck" "/usr/bin/shellcheck" \
    && rm -rf "./shellcheck-stable"

# Generate a machine-id for this container
RUN rm /etc/machine-id && dbus-uuidgen --ensure=/etc/machine-id