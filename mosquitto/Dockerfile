ARG BUILD_FROM
FROM $BUILD_FROM as builder

WORKDIR /usr/src
ARG MOSQUITTO_AUTH_VERSION
RUN apk add --no-cache --virtual .build-dependencies \
        build-base go git mosquitto-dev \
    && git clone --depth 1 https://github.com/iegomez/mosquitto-go-auth \
    && cd mosquitto-go-auth \
    && CGO_CFLAGS="-I/usr/include -fPIC" \
    && export CGO_LDFLAGS="-shared" \
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
