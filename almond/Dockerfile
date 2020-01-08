ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install Alomond requirements
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        software-properties-common \
        gnupg \
        nginx \
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
    && apt-get update && apt-get install -y --no-install-recommends \
        nodejs \
        yarn \
    && rm -rf /var/lib/apt/lists/*


# Install Almond
ARG ALMOND_VERSION
WORKDIR /opt/almond
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        python-dev \
        build-essential \
    \
    && git clone -b "${ALMOND_VERSION}" --depth 1 \
        "https://github.com/stanford-oval/almond-server" . \
    && rm -fr .git \
    && yarn \
    \
    && apt-get purge -y --auto-remove \
        git \
        python-dev \
        build-essential \
    && rm -rf \
        /var/lib/apt/lists/* \
        /root/.cache

# Base env settings
ENV LANG=en_US.utf8
ENV THINGENGINE_HOME=/data/almond-server
ENV THINGENGINE_HOST_BASED_AUTHENTICATION=local-ip

COPY data/run.sh /
COPY data/nginx.conf /etc/nginx/

CMD ["/run.sh"]