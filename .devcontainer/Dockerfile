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
        shellcheck

# Install docker
RUN curl -fsSL https://get.docker.com | sh -

# Generate a machine-id for this container
RUN rm /etc/machine-id && dbus-uuidgen --ensure=/etc/machine-id