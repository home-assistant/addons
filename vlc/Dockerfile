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
    && addgroup -S vlc && adduser -D -D -G vlc vlc # create vlc user to run vlc without patching vlc to run as root \
    && sed -i '197s#.*#    dir = dir == undefined ? "file:///media" : dir;#' /usr/share/vlc/lua/http/js/controllers.js
        
WORKDIR /
COPY rootfs /
