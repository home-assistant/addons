ARG BUILD_FROM
FROM $BUILD_FROM

# Install mosquitto + auth plugin
WORKDIR /usr/src
ARG LIBWEBSOCKET_VERSION
ARG MOSQUITTO_VERSION
ARG MOSQUITTO_AUTH_VERSION
RUN apt-get update \
    && apt-get install -qy --no-install-recommends \
        nginx \
        pwgen \
        build-essential \
        cmake \
        git \
        openssl \
        libssl-dev \
        libc-ares-dev \
        libcjson1 \
        libcjson-dev \
        xsltproc \
        docbook-xsl \
        golang-go \
    \
    # Compile and install libwebsocket
    && git clone --depth 1 -b "${LIBWEBSOCKET_VERSION}" \
       https://libwebsockets.org/repo/libwebsockets \
    \
    && cd libwebsockets \
    && mkdir build \
    && cd build \
    && cmake -DLWS_WITH_EXTERNAL_POLL=ON .. \
    && make install \
    && ldconfig \
    && cd ../.. \
    # Compile and install mosquitto
    && git clone --depth 1 -b "${MOSQUITTO_VERSION}" \
       https://github.com/eclipse/mosquitto \
    \
    && cd mosquitto \
    && make WITH_WEBSOCKETS=yes WITH_SRV=yes \
    && make install \
    && cd .. \
    # Compile and install mosquitto-go-auth
    && git clone --depth 1 -b "${MOSQUITTO_AUTH_VERSION}" \
       https://github.com/iegomez/mosquitto-go-auth \
    \
    && cd mosquitto-go-auth \
    && sed -i 's/-I\/usr\/local\/include/-I\/usr\/include/' Makefile \
    && sed -i 's/LDFLAGS := .*$/& -Wl,-unresolved-symbols=ignore-all/' Makefile \
    && make \
    && mkdir -p /usr/share/mosquitto \
    && cp -f go-auth.so /usr/share/mosquitto \
    && cp -f pw /usr/local/bin \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
        git \
        cmake \
        libssl-dev \
        libc-ares-dev \
        libcjson-dev \
        xsltproc \
        docbook-xsl \
        golang-go \
    && apt-get clean \
    && rm -fr \
        /etc/logrotate.d \
        /etc/mosquitto/* \
        /etc/nginx/* \
        /usr/share/nginx \
        /usr/src/libwebsockets \
        /usr/src/mosquitto \
        /usr/src/mosquitto-go-auth \
        /var/lib/nginx/html \
        /var/www \
        /var/lib/apt/lists/* \
	/root/.cache \
	/root/go

# Copy rootfs
COPY rootfs /

WORKDIR /
