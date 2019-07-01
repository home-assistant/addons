ARG BUILD_FROM
ARG ALPINE_VERSION
FROM homeassistant/amd64-base:$ALPINE_VERSION as builder

WORKDIR /usr/src
ARG MOSQUITTO_AUTH_VERSION
ARG BUILD_ARCH
RUN apk add --no-cache --virtual .build-dependencies \
        build-base go git mosquitto-dev \
    && git clone --depth 1 -b ${MOSQUITTO_AUTH_VERSION} https://github.com/iegomez/mosquitto-go-auth \
    && cd mosquitto-go-auth \
    && export CGO_CFLAGS="-I/usr/include -fPIC" CGO_LDFLAGS="-s -w" \
    && \
        if [ "${BUILD_ARCH}" = "armhf" ]; then \
            export CGO_ENABLED=0 GOARM=6 GOARCH=arm; \
        elif [ "${BUILD_ARCH}" = "armv7" ]; then \
            export CGO_ENABLED=0 GOARM=7 GOARCH=arm; \
        elif [ "${BUILD_ARCH}" = "aarch64" ]; then \
            export CGO_ENABLED=0 GOARCH=arm64; \
        elif [ "${BUILD_ARCH}" = "amd64" ]; then \
            export CGO_ENABLED=0 GOARCH=amd64; \
        elif [ "${BUILD_ARCH}" = "i386" ]; then \
            export CGO_ENABLED=0 GOARCH=386; \
        else \
            exit 1; \
        fi \
    && make \
    && apk del .build-dependencies


FROM $BUILD_FROM

# Install mosquitto + auth plugin
RUN apk add --no-cache \
        mosquitto curl openssl musl socat pwgen

# Copy data
COPY --from=builder /usr/src/mosquitto-go-auth/go-auth.so /usr/share/mosquitto/
COPY data/run.sh /
COPY data/auth_srv.sh /bin/
COPY data/mosquitto.conf /etc/

WORKDIR /
CMD [ "/run.sh" ]
