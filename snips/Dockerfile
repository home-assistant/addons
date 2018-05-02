ARG BUILD_FROM
FROM $BUILD_FROM

# Copy data
COPY run.sh /
COPY mosquitto.conf /etc/
COPY mpg123* /usr/bin/
COPY customtts.sh /usr/bin
COPY assistant_* /

RUN chmod a+x /run.sh
RUN chmod a+x /usr/bin/customtts.sh

ENTRYPOINT [ "/run.sh" ]
