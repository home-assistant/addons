ARG BUILD_FROM
FROM $BUILD_FROM

# Install packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        python3-dev \
        python3-pip \
        libportaudio2 \
        alsa-utils \
    && pip3 install --no-cache-dir --upgrade \
        setuptools==41.0.1 \
        pip==19.1 \
    && pip3 install --no-cache-dir \
        google-assistant-library==1.0.0 \
        google-assistant-sdk==0.5.0 \
        google-assistant-grpc==0.2.0 \
        google-auth==1.6.3 \
        requests_oauthlib==1.2.0 \
        cherrypy==18.1.1 \
    && apt-get remove -y --purge python3-pip python3-dev \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Copy data
COPY run.sh /
COPY *.py /

ENTRYPOINT [ "/run.sh" ]
