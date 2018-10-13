ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Install mosquitto + auth plugin
WORKDIR /usr/src
ARG MOSQUITTO_AUTH_VERSION
RUN apk add --no-cache \
        mosquitto mosquitto-libs curl libressl musl socat \
    && apk add --no-cache --virtual .build-dependencies \
        gcc make git mosquitto-dev curl-dev libressl-dev musl-dev \
    && git clone --depth 1 -b $MOSQUITTO_AUTH_VERSION https://github.com/jpmens/mosquitto-auth-plug \
    && cd mosquitto-auth-plug \
    && cp config.mk.in config.mk \
    && sed -i "s/?= yes/?= no/g" config.mk \
    && sed -i "s/HTTP ?= no/HTTP ?= yes/g" config.mk \
    && make \
    && mkdir -p /usr/share/mosquitto \
    && cp -f auth-plug.so /usr/share/mosquitto \
    && apk del .build-dependencies \
    && rm -fr /usr/src/mosquitto-auth-plug

# Install auth own auth layer
COPY auth_srv.py /usr/src/
RUN apk add --no-cache --virtual .build-dependencies \
        python3-dev \
    && pip3 install --no-cache-dir pyinstaller aiohttp \
    && mkdir -p /usr/src/auth-srv \
    && mv auth_srv.py /usr/src/auth-srv/ \
    && cd /usr/src/auth-srv/ \
    && pyinstaller auth_srv.py \
    && apk del .build-dependencies \
    && rm -fr /usr/src/auth-srv

# Copy data
COPY run.sh /
COPY mosquitto.conf /etc/

RUN chmod a+x /run.sh

WORKDIR /
CMD [ "/run.sh" ]
