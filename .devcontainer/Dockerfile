FROM ubuntu:18.04

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
        dbus \
        software-properties-common \
        gpg-agent \
        git \
        sudo \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
    && add-apt-repository "deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update && apt-get install -y --no-install-recommends \
        docker-ce \
        docker-ce-cli \
        containerd.io
# This is a development container.  Don't bother to clean up apt cache, this way we have it handy later

COPY .devcontainer/start_hassio.sh /usr/local/bin/start_hassio.sh

# Generate a machine-id for this container
RUN rm /etc/machine-id && dbus-uuidgen --ensure=/etc/machine-id

ENV DEBIAN_FRONTEND=dialog