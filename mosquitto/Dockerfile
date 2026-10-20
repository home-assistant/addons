ARG BUILD_FROM
FROM $BUILD_FROM

# Install mosquitto + auth plugin
WORKDIR /usr/src
ARG LIBWEBSOCKET_VERSION
ARG MOSQUITTO_VERSION
ARG MOSQUITTO_AUTH_VERSION
COPY patches/0001-Fix-builtin-websockets-dropping-the-session-on-an-empty-data-frame.patch /usr/src
RUN apt-get update \
    && apt-get install -qy --no-install-recommends \
        nginx \
        pwgen \
        build-essential \
        cmake \
        git \
        openssl \
        patch \
        libssl-dev \
        libc-ares2 \
        libc-ares-dev \
        libcjson1 \
        libcjson-dev \
        libsqlite3-dev \
        xsltproc \
        docbook-xsl \
        golang-go \
    \
    # Compile and install libwebsocket
    #
    # DLWS_WITHOUT_TESTAPPS is just a workaround, see
    # https://github.com/warmcat/libwebsockets/issues/2790 for more
    && git clone --depth 1 -b "v${LIBWEBSOCKET_VERSION}" \
       https://github.com/warmcat/libwebsockets \
    \
    && cd libwebsockets \
    && mkdir build \
    && cd build \
    && cmake -DLWS_WITH_EXTERNAL_POLL=ON -DLWS_WITHOUT_TESTAPPS=ON .. \
    && make install \
    && ldconfig \
    && cd ../.. \
    # Compile and install mosquitto
    && git clone --depth 1 -b "v${MOSQUITTO_VERSION}" \
       https://github.com/eclipse/mosquitto \
    \
    && cd mosquitto \
    && patch -p1 < /usr/src/0001-Fix-builtin-websockets-dropping-the-session-on-an-empty-data-frame.patch \
    # Disable editline used by mosquitto_ctrl
    && sed -i 's/^WITH_EDITLINE=yes/#WITH_EDITLINE=yes/' config.mk \
    # Disable REST API
    && sed -i 's/^WITH_HTTP_API=yes/#WITH_HTTP_API=yes/' config.mk \
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
    # Fix nil pointer dereference panic in ttlcache
    && sed -i 's/return present, item.Value()/if item == nil { return false, false }\n\treturn true, item.Value()/' cache/cache.go \
    && make \
    && mkdir -p /usr/share/mosquitto \
    && cp -f go-auth.so /usr/share/mosquitto \
    && cp -f pw /usr/local/bin \
    \
    && apt-get purge -y --auto-remove \
        build-essential \
        git \
        patch \
        cmake \
        libssl-dev \
        libc-ares-dev \
        libcjson-dev \
        libsqlite3-dev \
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
        /usr/src/*.patch \
        /var/lib/nginx/html \
        /var/www \
        /var/lib/apt/lists/* \
	/root/.cache \
	/root/go

# Copy rootfs
COPY rootfs /

WORKDIR /
