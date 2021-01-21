ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG ZWAVEJS_SERVER_VERSION

# Install QT Open Z-Wave 
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
    && npm install -g typescript \
    && npm install -g --production @zwave-js/server@${ZWAVEJS_SERVER_VERSION} \
    \
    && apk del --no-cache \
        .build-dependencies

WORKDIR /
COPY rootfs /
