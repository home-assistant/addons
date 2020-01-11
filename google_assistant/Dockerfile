ARG BUILD_FROM
FROM $BUILD_FROM

# Install packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        alsa-utils \
        libportaudio2 \
        python3 \
        python3-dev \
    && curl --silent --show-error --retry 5 \
        "https://bootstrap.pypa.io/get-pip.py" \
        | python3 \
    && pip3 install --no-cache-dir \
        cherrypy==18.1.1 \
        google-assistant-grpc==0.2.0 \
        google-assistant-library==1.0.0 \
        google-assistant-sdk==0.5.0 \
        google-auth==1.6.3 \
        requests_oauthlib==1.2.0 \
    && apt-get remove -y --purge python3-dev \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Copy data
COPY data/* /

ENTRYPOINT [ "/run.sh" ]
