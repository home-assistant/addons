ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
RUN apk add --no-cache jq curl git openssh-client

# Home Assistant CLI
ARG BUILD_ARCH
ARG CLI_VERSION
RUN curl -Lso /usr/bin/ha \
        "https://github.com/home-assistant/cli/releases/download/${CLI_VERSION}/ha_${BUILD_ARCH}" \
    && chmod a+x /usr/bin/ha

# Copy data
COPY data/run.sh /

CMD [ "/run.sh" ]
