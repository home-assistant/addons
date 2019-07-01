ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Install mosquitto + auth plugin
WORKDIR /usr/src
ARG MOSQUITTO_AUTH_VERSION
RUN apk add --no-cache \
        mosquitto curl openssl musl socat pwgen \
    && apk add --no-cache --virtual .build-dependencies \
        build-base go git mosquitto-dev \
    && git clone --depth 1 https://github.com/iegomez/mosquitto-go-auth \
    && cd mosquitto-go-auth \
    && CGO_CFLAGS="-I/usr/include -fPIC" \
    && export CGO_LDFLAGS="-shared" \
    && make \
    && mkdir -p /usr/share/mosquitto \
    && cp -f go-auth.so /usr/share/mosquitto \
    && apk del .build-dependencies \
    && rm -fr /usr/src/mosquitto-go-auth

# Copy data
COPY data/run.sh /
COPY data/auth_srv.sh /bin/
COPY data/mosquitto.conf /etc/

WORKDIR /
CMD [ "/run.sh" ]
