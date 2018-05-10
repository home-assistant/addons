ARG BUILD_FROM
FROM $BUILD_FROM

# Install packages
RUN apt-get update \
    && apt-get install -y \
        jq tzdata python3 python3-dev python3-pip libportaudio2 alsa-utils \
    && pip3 install --no-cache-dir --upgrade pip setuptools \
    && pip3 install --no-cache-dir \
        google-assistant-library==1.0.0 \
        google-assistant-sdk==0.5.0 \
        google-assistant-grpc==0.2.0 \
        google-auth requests_oauthlib cherrypy \
    && apt-get remove -y --purge python3-pip python3-dev \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Copy data
COPY run.sh /
COPY *.py /

RUN chmod a+x /run.sh

ENTRYPOINT [ "/run.sh" ]
