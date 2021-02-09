ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG ZWAVEJS_SERVER_VERSION
ARG ZWAVEJS_VERSION

# Install Z-Wave JS
WORKDIR /usr/src
RUN \
    set -x \
    && apk add --no-cache \
        nodejs \
        npm \
    && apk add --no-cache --virtual .build-dependencies \
        build-base \
        git \
        linux-headers \
        python3 \
    \
    && npm config set unsafe-perm \
    && npm install -g @zwave-js/server@${ZWAVEJS_SERVER_VERSION} zwave-js@${ZWAVEJS_VERSION} \
    \
    && apk del --no-cache \
        .build-dependencies

WORKDIR /
COPY rootfs /
