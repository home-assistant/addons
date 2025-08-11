ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install VLC
WORKDIR /usr/src
RUN \
    set -x \
    && apk add --no-cache \
        inotify-tools \
        nginx \
        pwgen \
        vlc \
    && sed -i 's/geteuid/getppid/' /usr/bin/vlc \
    && sed -i '197s#.*#    dir = dir == undefined ? "file:///media" : dir;#' /usr/share/vlc/lua/http/js/controllers.js
        
WORKDIR /
COPY rootfs /
