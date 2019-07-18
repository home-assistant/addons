ARG BUILD_FROM
FROM $BUILD_FROM

# Add Hass.io wheels repository
ARG BUILD_ARCH
ENV WHEELS_LINKS=https://wheels.home-assistant.io/alpine-3.10/${BUILD_ARCH}/

# Copy data
COPY data/run.sh /

CMD [ "/run.sh" ]
