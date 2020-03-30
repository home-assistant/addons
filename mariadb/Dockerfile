ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
RUN apk add --no-cache \
    mariadb \
    mariadb-client \
    mariadb-server-utils \
    pwgen

# Install jemalloc
WORKDIR /usr/src
ARG JEMALLOC_VERSION
RUN apk add --no-cache --virtual .build-deps \
        build-base \
    && curl -L -s https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VERSION}/jemalloc-${JEMALLOC_VERSION}.tar.bz2 | tar -xjf - -C /usr/src \
    && cd /usr/src/jemalloc-${JEMALLOC_VERSION} \
    && ./configure \
    && make \
    && make install \
    && apk del .build-deps \
    && rm -rf /usr/src/jemalloc-${JEMALLOC_VERSION}

ENV LD_PRELOAD="/usr/local/lib/libjemalloc.so.2"

# Copy data
COPY rootfs /

WORKDIR /
