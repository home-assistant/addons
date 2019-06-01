ARG BUILD_FROM
FROM $BUILD_FROM

# Add Hass.io wheels repository
ARG BUILD_ARCH
ENV WHEELS_LINKS=https://wheels.home-assistant.io/alpine-3.9/${BUILD_ARCH}/

# Copy data
COPY run.sh /

CMD [ "/run.sh" ]
