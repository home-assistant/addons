ARG BUILD_FROM
FROM $BUILD_FROM

# Copy data
COPY run.sh /
COPY mosquitto.conf /etc/
COPY asoundrc /root/.asoundrc

ARG ASSISTANT_URL
ADD $ASSISTANT_URL /assistant-default.zip

RUN chmod a+x /run.sh

ENTRYPOINT [ "/run.sh" ]
