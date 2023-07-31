ARG BUILD_FROM
ARG BUILD_ARCH

FROM $BUILD_FROM

ARG UNIVERSAL_SILABS_FLASHER

RUN \
    set -x \
    && apk add --no-cache \
        py3-pip \
        python3 \
    && apk add --no-cache --virtual .tmp-build-deps \
        gcc \
        libc-dev \
        libffi-dev \
        python3-dev \
    && pip3 install \
        --no-cache-dir \
        --prefer-binary \
        --find-links "https://wheels.home-assistant.io/musllinux/${BUILD_ARCH}/" \
        universal-silabs-flasher=="${UNIVERSAL_SILABS_FLASHER}" \
    && apk del .tmp-build-deps

COPY rootfs /

# use s6-overlay as init system
WORKDIR /
ENTRYPOINT ["/init"]
