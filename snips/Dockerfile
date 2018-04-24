ARG BUILD_FROM
FROM $BUILD_FROM

# Copy data
COPY run.sh /
COPY mosquitto.conf /etc/
COPY mpg123* /usr/bin/
COPY assistant-* /

RUN chmod a+x /run.sh

ENTRYPOINT [ "/run.sh" ]
