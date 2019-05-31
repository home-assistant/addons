ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
RUN apk add --no-cache \
        jq \
        gcc \
        libffi-dev \
        openssl-dev \
        musl-dev

# Copy data
COPY run.sh /

CMD [ "/run.sh" ]
