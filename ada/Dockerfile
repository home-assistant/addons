ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install Dude
WORKDIR /usr/src/ada
ARG ADA_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
        portaudio19-dev \
        libsndfile1 \
        mplayer \
        libffi-dev \
        python3 \
        python3-pip \
        python3-dev \
        git \
        build-essential \
    \
    && git clone --depth 1 -b ${ADA_VERSION} https://github.com/home-assistant/dude . \
    && rm -rf .git \
    && pip3 install -U setuptools wheel \
    && pip3 install -r requirements.txt \
    && pip3 install -e . \
    && python3 -m compileall dude \
    \
    && apt-get purge -y --auto-remove \
        git \
        build-essential \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /
COPY data/run.sh /

CMD ["/run.sh"]
