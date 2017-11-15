ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install Telldus library for TellStick (using same approach as in hassio docker installation)
RUN apk add --no-cache \
        confuse libftdi1 libstdc++ jq socat \
    && apk add --no-cache --virtual .build-dependencies \
        cmake build-base gcc doxygen confuse-dev argp-standalone libftdi1-dev git \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone -b master --depth 1 https://github.com/telldus/telldus \
    && cd telldus/telldus-core \
    && sed -i "/\<sys\/socket.h\>/a \#include \<sys\/select.h\>" common/Socket_unix.cpp \
    && cmake . -DBUILD_LIBTELLDUS-CORE=ON -DBUILD_TDADMIN=ON -DBUILD_TDTOOL=ON -DGENERATE_MAN=OFF -DFORCE_COMPILE_FROM_TRUNK=ON -DFTDI_LIBRARY=/usr/lib/libftdi1.so \
    && make \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/telldus

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
