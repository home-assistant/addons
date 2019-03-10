ARG BUILD_FROM
FROM $BUILD_FROM AS builder

RUN apk add --no-cache go git musl-dev
RUN go get github.com/adnanh/webhook

FROM $BUILD_FROM

# Setup base
RUN apk add --no-cache jq curl git openssh-client

# Hass.io CLI
ARG BUILD_ARCH
ARG CLI_VERSION
RUN apk add --no-cache curl \
    && curl -Lso /usr/bin/hassio https://github.com/home-assistant/hassio-cli/releases/download/${CLI_VERSION}/hassio_${BUILD_ARCH} \
    && chmod a+x /usr/bin/hassio

# Webhook server
COPY --from=builder /root/go/bin/webhook /usr/bin

# Copy data
COPY run.sh /
COPY hook-template.json /

CMD [ "/run.sh" ]
