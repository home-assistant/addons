ARG BUILD_FROM
FROM $BUILD_FROM

# Install mosquitto + auth plugin
WORKDIR /usr/src
ARG MOSQUITTO_AUTH_VERSION
RUN apk add --no-cache \
        curl \
        mosquitto \
        musl \
        openssl \
        pwgen \
        socat \
    && apk add --no-cache --virtual .build-dependencies \
        build-base \
        curl-dev \
        git \
        mosquitto-dev \
        openssl-dev \
    \
    && git clone --depth 1 -b "${MOSQUITTO_AUTH_VERSION}" \
        https://github.com/pvizeli/mosquitto-auth-plug \
    && cd mosquitto-auth-plug \
    && cp config.mk.in config.mk \
    && make \
    && mkdir -p /usr/share/mosquitto \
    && cp -f auth-plug.so /usr/share/mosquitto \
    \
    && apk del .build-dependencies \
    && rm -fr /usr/src/mosquitto-auth-plug

# Copy data
COPY data/run.sh /
COPY data/auth_srv.sh /bin/
COPY data/mosquitto.conf /etc/

WORKDIR /
CMD [ "/run.sh" ]
