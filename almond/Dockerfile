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
    apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        gnupg \
        nginx \
        python-dev \
        software-properties-common \
        unzip \
    \
    && curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key \
        | apt-key add - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg \
        | apt-key add - \
    && echo "deb https://deb.nodesource.com/node_12.x buster main" \
        > /etc/apt/sources.list.d/nodesource.list \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" \
        > /etc/apt/sources.list.d/yarn.list \
    \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        nodejs \
        yarn \
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
    && apt-get purge -y --auto-remove \
        build-essential \
        git \
        gnupg \
        python-dev \
        software-properties-common \
        yarn \
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

COPY rootfs /
