ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Install mosquitto + auth plugin
WORKDIR /usr/src
ARG MOSQUITTO_AUTH_VERSION
RUN apk add --no-cache \
        mosquitto curl libressl musl socat \
    && apk add --no-cache --virtual .build-dependencies \
        gcc make git mosquitto-dev curl-dev libressl-dev musl-dev \
    && git clone --depth 1 https://github.com/jpmens/mosquitto-auth-plug \
    && cd mosquitto-auth-plug \
    && cp config.mk.in config.mk \
    && sed -i "s/?= yes/?= no/g" config.mk \
    && sed -i "s/HTTP ?= no/HTTP ?= yes/g" config.mk \
    && make \
    && mkdir -p /usr/share/mosquitto \
    && cp -f auth-plug.so /usr/share/mosquitto \
    && apk del .build-dependencies \
    && rm -fr /usr/src/mosquitto-auth-plug

# Copy data
COPY run.sh /
COPY auth_srv.sh /bin/
COPY mosquitto.conf /etc/

RUN chmod a+x /run.sh /bin/auth_srv.sh

WORKDIR /
CMD [ "/run.sh" ]
