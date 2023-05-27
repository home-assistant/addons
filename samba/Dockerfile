ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN \
    apk add --no-cache \
        samba-common-tools \
        samba-server \
        dbus \
        exfatprogs \
        btrfs-progs \
        xfsprogs \
        udev \
        e2fsprogs \
        util-linux \
        findmnt \
        ntfs-3g-progs \
    \
    && mkdir -p /var/lib/samba \
    && touch \
        /etc/samba/lmhosts \
        /var/lib/samba/account_policy.tdb \
        /var/lib/samba/registry.tdb \
        /var/lib/samba/winbindd_idmap.tdb

# Copy data
COPY rootfs /
