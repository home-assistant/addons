#ARG BUILD_FROM
#FROM $BUILD_FROM
FROM snipsdocker/platform:x86-0.51.14

# Copy data
COPY run.sh /
COPY mosquitto.conf /etc/
COPY asoundrc /root/.asoundrc

ADD https://github.com/tschmidty69/hassio-snips/releases/download/0.1-pre1/assistant.zip /assistant-default.zip

RUN chmod a+x /run.sh

ENTRYPOINT [ "/run.sh" ]
