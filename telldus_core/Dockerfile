ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install telldus-core on alipne linux using git source from telldus.

# Add dependancie libs, build libs
# Patch files and script for patching to enable compilation on Alpine linux	then compile and install, without tdadmin and pointing config file in to /config.
# NOTE: installation will overwrite /config/tellstick.conf if it exists - backup routine needed?
# Optional - Include patch file in add-on to avoid retreiving from git or use bjornes fork of telldus with modified files.

RUN mkdir /usr/src \
	&& cd /usr/src \
	&& apk add --no-cache \
        confuse libftdi1 libstdc++ \
    && apk add --no-cache --virtual .build-dependencies \
        cmake build-base gcc doxygen confuse-dev argp-standalone libftdi1-dev git \
	&& git clone -b master https://github.com/telldus/telldus \
	&& git clone -b master https://github.com/endor-force/telldus-core-alpine \
	&& cd /usr/src/telldus \
    && patch -p1 -i ../telldus-core-alpine/telldus-alpine.patch \
	&& cd telldus-core \
    && cmake . -DFORCE_COMPILE_FROM_TRUNK=YES -DSYSCONF_INSTALL_DIR=/config -DBUILD_TDADMIN=false \
    && make -j1 \
    && make install \
    && apk del .build-dependencies \
    && rm -rf /usr/src/telldus \
	&& rm -rf /usr/src/telldus-core-alpine



# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]