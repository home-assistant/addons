ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install requirements
WORKDIR /usr/src
COPY data/requirements .
RUN apt-get update && apt-get install -y --no-install-recommends \
        portaudio19-dev \
        python3 \
        python3-pip \
    \
    && pip3 install -r requirements.txt \
    \
    && rm -f requirements.txt \
    && rm -rf /var/lib/apt/lists/*

COPY data/run.sh /

CMD ["/run.sh"]