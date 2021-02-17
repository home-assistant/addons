ARG BUILD_FROM
FROM ${BUILD_FROM}

# Base env settings
ENV \
    LANG="en_US.utf8" \
    THINGENGINE_HOME="/data/almond-server" \
    THINGENGINE_HOST_BASED_AUTHENTICATION="local-ip"

WORKDIR /opt/almond
ARG ALMOND_VERSION

RUN \
    set -x \
    && apk add --no-cache \
        nodejs \
        npm \
        yarn \
        nginx \
        unzip \
    && apk add --no-cache --virtual .build-dependencies \
        build-base \
        git \
        linux-headers \
        python3 \
    \
    && npm config set unsafe-perm \
    \
    && git clone -b "${ALMOND_VERSION}" --depth 1 \
        "https://github.com/stanford-oval/almond-server" . \
    && rm -fr .git \
    && yarn \
    \
    && yarn global add modclean \
    && modclean \
        --path /opt/almond \
        --no-progress \
        --keep-empty \
        --run \
    && yarn global remove modclean \
    \
    && yarn cache clean \
    && rm -rf \
        /opt/almond/.[!.]* \
        /root/.cache \
        /root/.config \
        /tmp/.[!.]* \
        /tmp/* \
        /usr/lib/nginx \
        /usr/local/share/.cache \
        /usr/local/share/.config \
        /var/lib/apt/lists/* \
        /var/www

    \
    && apk del --no-cache \
        .build-dependencies

COPY rootfs /
