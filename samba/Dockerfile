ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN \
    echo '@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> \
        /etc/apk/repositories && \
    apk add --no-cache samba mdnsd@testing=0.12-r1 \
    && rm -f /etc/mdns.d/* \
    && mkdir -p /var/lib/samba /smbshare \
    && touch \
        /etc/samba/lmhosts \
        /var/lib/samba/account_policy.tdb \
        /var/lib/samba/registry.tdb \
        /var/lib/samba/winbindd_idmap.tdb

# Copy data
COPY rootfs /

HEALTHCHECK --start-period=3s \
    CMD smbclient -L '\\localhost' -U '%' -m SMB3
