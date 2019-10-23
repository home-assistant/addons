ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install Alomond requirements
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        software-properties-common \
        gnupg \
    \
    && curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://deb.nodesource.com/node_12.x buster main" > /etc/apt/sources.list.d/nodesource.list \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    \
    && apt-get update && apt-get install -y --no-install-recommends \
        nodejs \
        yarn \
    && rm -rf /var/lib/apt/lists/*


# Install Almond
ARG ALMOND_COMMIT
WORKDIR /opt/almond
RUN git clone https://github.com/stanford-oval/almond-server . \
    && git checkout ${ALMOND_COMMIT} \
    && rm -fr .git \
    \
    && apt-get update && apt-get install -y --no-install-recommends \
        python-dev \
        build-essential \
    && yarn \
    && apt-get purge -y --auto-remove \
        python-dev \
        build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && rm -fr /root/.cache

ENV THINGENGINE_HOME=/data/almond-server
COPY data/run.sh /

CMD ["/run.sh"]