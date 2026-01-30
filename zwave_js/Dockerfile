ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG ZWAVEJS_SERVER_VERSION
ARG ZWAVEJS_VERSION

# Environment configuration
ENV \
    S6_KILL_GRACETIME=30000 \
    S6_SERVICES_GRACETIME=30000 \
    STORE_DIR=/config

# Install Z-Wave JS UI
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
    # && npm install -g "zwave-js-ui@${ZWAVEJS_UI_VERSION}" \
    && npm install -g "https://github.com/zwave-js/zwave-js-ui/raw/refs/heads/external-port-setting/zwave-js-ui-11.10.2-alpha.4.tgz" \
    \
    && apk del --no-cache \
        .build-dependencies

WORKDIR /
COPY rootfs /

ENV PATH=/usr/src/node_modules/.bin:$PATH
