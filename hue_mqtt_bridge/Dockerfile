ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8
ENV INSTALL_PATH="/bin/hue-mqtt-bridge"

# Setup base
RUN apk add --no-cache git nodejs

# Hass.io CLI
ARG BUILD_ARCH
ARG CLI_VERSION
RUN apk add --no-cache curl \
    && curl -Lso /usr/bin/hassio https://github.com/home-assistant/hassio-cli/releases/download/${CLI_VERSION}/hassio_${BUILD_ARCH} \
    && chmod a+x /usr/bin/hassio

# Install hue mqtt bridge
RUN mkdir "$INSTALL_PATH"
RUN git clone https://github.com/dale3h/hue-mqtt-bridge.git "$INSTALL_PATH"
RUN cd "$INSTALL_PATH" && npm i

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
