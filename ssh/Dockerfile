ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
ARG LIBWEBSOCKETS_VERSION
ARG TTYD_VERSION
RUN \
    apk add --no-cache --virtual .build-dependencies \
        bsd-compat-headers \
        build-base \
        cmake \
        json-c-dev \
        libuv-dev \
        openssl-dev \
    \
    && apk add --no-cache \
        bash-completion \
        git \
        libuv \
        mosquitto-clients \
        nano \
        openssh \
        pwgen \
        tmux \
        vim \
    \
    && sed -i "s/ash/bash/" /etc/passwd \
    \
    && git clone --branch "${LIBWEBSOCKETS_VERSION}" --depth=1 \
        https://github.com/warmcat/libwebsockets.git /tmp/libwebsockets \
    \
    && mkdir -p /tmp/libwebsockets/build \
    && cd /tmp/libwebsockets/build \
    && cmake .. \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_VERBOSE_MAKEFILE=TRUE \
        -DLWS_IPV6=ON \
        -DLWS_STATIC_PIC=ON \
        -DLWS_UNIX_SOCK=OFF \
        -DLWS_WITH_LIBUV=ON \
        -DLWS_WITH_SHARED=ON \
        -DLWS_WITHOUT_TESTAPPS=ON \
    && make \
    && make install \
    \
    && git clone --branch master --single-branch \
        https://github.com/tsl0922/ttyd.git /tmp/ttyd \
    && git -C /tmp/ttyd checkout "${TTYD_VERSION}" \
    \
    && mkdir -p /tmp/ttyd/build \
    && cd /tmp/ttyd/build \
    && cmake .. \
        -DCMAKE_BUILD_TYPE=MinSizeRel \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_VERBOSE_MAKEFILE=TRUE \
    && make \
    && make install \
    \
    && apk del --no-cache --purge .build-dependencies \
    && rm -f -r \
        /root/.cache \
        /root/.cmake \
        /tmp/*

# Add YAML highlighting for nano
ADD https://raw.githubusercontent.com/scopatz/nanorc/master/yaml.nanorc /usr/share/nano/yaml.nanorc
RUN sed -i 's/^#[[:space:]]*\(include "\/usr\/share\/nano\/\*\.nanorc".*\)/\1/' /etc/nanorc

# Home Assistant CLI
ARG BUILD_ARCH
ARG CLI_VERSION
RUN curl -Lso /usr/bin/hassio \
        "https://github.com/home-assistant/hassio-cli/releases/download/${CLI_VERSION}/hassio_${BUILD_ARCH}" \
    && chmod a+x /usr/bin/hassio \
    && /usr/bin/hassio completion > /usr/share/bash-completion/completions/hassio

# Copy data
COPY data/.tmux.conf /root/
COPY data/hassio.sh /etc/profile.d/
COPY data/motd /etc/
COPY data/run.sh /
COPY data/sshd_config /etc/ssh/

CMD [ "/run.sh" ]
