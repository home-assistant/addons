ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG ZWAVEJS_SERVER_VERSION
ARG ZWAVEJS_VERSION

# Environment configuration
ENV \
    S6_KILL_GRACETIME=30000 \
    S6_SERVICES_GRACETIME=30000

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
    && npm install --force \
        "zwave-js@${ZWAVEJS_VERSION}" \
        "@zwave-js/server@${ZWAVEJS_SERVER_VERSION}" \
    \
    && npm rebuild --build-from-source @serialport/bindings-cpp \
    && apk del --no-cache \
        .build-dependencies

WORKDIR /
COPY rootfs /

ENV PATH=/usr/src/node_modules/.bin:$PATH
