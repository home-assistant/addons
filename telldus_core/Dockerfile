ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install telldus-core on alipne linux using forked telldus source with modifications for alpine.


# Install Telldus library for TellStick (using same approach as in hassio docker installation)
RUN apk add --no-cache \
        confuse libftdi1 libstdc++ \
	&& apk add --no-cache --virtual .build-dependencies \
        	cmake build-base gcc doxygen confuse-dev argp-standalone libftdi1-dev git \
	&& mkdir /usr/src \
	&& cd /usr/src \
	&& git clone -b homeassistant-alpine --depth 1 https://github.com/bjorne/telldus \
	&& cd telldus/telldus-core \
	&& cmake . -DBUILD_LIBTELLDUS-CORE=ON -DBUILD_TDADMIN=OFF -DBUILD_TDTOOL=ON -DGENERATE_MAN=OFF -DFORCE_COMPILE_FROM_TRUNK=ON -DSYSCONF_INSTALL_DIR=/config \
	&& make \
	&& make install \
	&& cp /usr/src/telldus/telldus-core/service/tellstick.conf /usr/src \
	&& apk del .build-dependencies \
	&& rm -rf /usr/src/telldus


# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
