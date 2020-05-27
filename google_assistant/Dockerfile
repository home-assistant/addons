ARG BUILD_FROM
FROM $BUILD_FROM

ARG GOOGLE_GRPC_VERSION
ARG GOOGLE_LIBRARY_VERSION
ARG GOOGLE_SDK_VERSION 
ARG GOOGLE_AUTH_VERSION
ARG REQUESTS_OAUTHLIB_VERSION
ARG CHERRYPY_VERSION

# Install packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libportaudio2 \
        libasound2-plugins \
        pulseaudio-utils \
        python3 \
        python3-dev \
        build-essential \
    && curl --silent --show-error --retry 5 \
        "https://bootstrap.pypa.io/get-pip.py" \
        | python3 \
    && pip3 install --no-cache-dir \
        cherrypy=="${CHERRYPY_VERSION}" \
        google-assistant-grpc=="${GOOGLE_GRPC_VERSION}" \
        google-assistant-library=="${GOOGLE_LIBRARY_VERSION}" \
        google-assistant-sdk=="${GOOGLE_SDK_VERSION}" \
        google-auth=="${GOOGLE_AUTH_VERSION}" \
        requests_oauthlib=="${REQUESTS_OAUTHLIB_VERSION}" \
    && apt-get remove -y --purge \
        python3-dev \
        build-essential \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Copy data
COPY rootfs /
