ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache \
        rsync

# Copy data
COPY rootfs /
