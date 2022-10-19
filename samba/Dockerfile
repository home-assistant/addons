ARG BUILD_FROM
FROM $BUILD_FROM AS builder

RUN apk add --update --no-cache \
  make \
  gcc \
  musl-dev \
  git \
  linux-headers
RUN git clone https://github.com/Netgear/wsdd2.git --depth=1
RUN cd /wsdd2/ && make && find /wsdd2

FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN \
    apk add --no-cache \
        samba-common-tools \
        samba-server \
    \
    && mkdir -p /var/lib/samba \
    && touch \
        /etc/samba/lmhosts \
        /var/lib/samba/account_policy.tdb \
        /var/lib/samba/registry.tdb \
        /var/lib/samba/winbindd_idmap.tdb

# Copy WSDD
COPY --from=0 /wsdd2/wsdd2 /usr/bin

# Copy data
COPY rootfs /
