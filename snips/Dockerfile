ARG BUILD_FROM
FROM $BUILD_FROM

# Copy data
COPY run.sh /
COPY mosquitto.conf /etc/
COPY mpg123* /usr/bin/
COPY customtts.sh /usr/bin
COPY assistant_* /

RUN chmod a+x /run.sh

ENTRYPOINT [ "/run.sh" ]
