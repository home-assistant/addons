ARG BUILD_FROM
FROM $BUILD_FROM

# Install mosquitto + auth plugin
WORKDIR /usr/src
ARG MOSQUITTO_AUTH_VERSION
RUN apk add --no-cache \
        mosquitto \
        nginx \
        pwgen \
    && apk add --no-cache --virtual .build-dependencies \
        build-base \
        curl-dev \
        git \
        mosquitto-dev \
        openssl-dev \
    \
    && git clone --depth 1 -b "${MOSQUITTO_AUTH_VERSION}" \
        https://github.com/pvizeli/mosquitto-auth-plug \
    \
    && cd mosquitto-auth-plug \
    && cp config.mk.in config.mk \
    && make \
    && mkdir -p /usr/share/mosquitto \
    && cp -f auth-plug.so /usr/share/mosquitto \
    && cp -f np /usr/local/bin \
    \
    && apk del --no-cache .build-dependencies \
    && rm -fr \
        /etc/logrotate.d \
        /etc/mosquitto/* \
        /etc/nginx/* \
        /usr/share/nginx \
        /usr/src/mosquitto-auth-plug \
        /var/lib/nginx/html \
        /var/www

# Copy rootfs
COPY rootfs /

WORKDIR /
