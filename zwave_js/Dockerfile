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
    && npm install -g ts-node \
    \
    && git clone --depth 1 -b \
        ${ZWAVEJS_SERVER_VERSION} https://github.com/zwave-js/zwave-js-server /usr/src/zwavejs-server \
    && cd /usr/src/zwavejs-server \
    && npm install \
    \
    && apk del --no-cache \
        .build-dependencies

WORKDIR /
COPY rootfs /
