ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install Dude
WORKDIR /usr/src
ARG DUDE_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
        portaudio19-dev \
        python3 \
        python3-pip \
        git \
    \
    && git clone --depth 1 -b ${DUDE_VERSION} https://github.com/home-assistant/dude \
    && pip3 install -r ./dude/requirements.txt \
    && pip3 install -e ./dude \
    && python3 -m compileall ./dude/dude \
    \
    && apt-get purge -y --auto-remove \
        git \
    && rm -rf /var/lib/apt/lists/*

COPY data/run.sh /

CMD ["/run.sh"]