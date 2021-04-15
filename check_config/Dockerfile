ARG BUILD_FROM
FROM $BUILD_FROM

# Workaround until is merged:
# https://github.com/home-assistant/docker/pull/181
ENV USING_UDEV=0

RUN apk add --no-cache \
        rsync

# Copy data
COPY rootfs /
