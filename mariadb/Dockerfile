ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
RUN apk add --no-cache \
    mariadb \
    mariadb-client \
    mariadb-server-utils \
    pwgen

ENV \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so.2" \
    S6_SERVICES_GRACETIME=18000 \
    MARIADB_AUTO_UPGRADE=1

# Copy data
COPY rootfs /

WORKDIR /
