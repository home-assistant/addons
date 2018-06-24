ARG BUILD_FROM
FROM $BUILD_FROM

# Copy data
COPY run.sh /
COPY mosquitto.conf /etc/
COPY customtts.sh /usr/bin
COPY assistant_* /

RUN chmod a+x /run.sh \
    && chmod a+x /usr/bin/customtts.sh \
    && apt-get update \
    && (apt-get install -y mpg123 snips-asr-injection; exit 0) \
    && apt-get clean all

ENTRYPOINT [ "/run.sh" ]
