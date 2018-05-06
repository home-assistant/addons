ARG BUILD_FROM
FROM $BUILD_FROM

# Copy data
COPY run.sh /
COPY mosquitto.conf /etc/
COPY customtts.sh /usr/bin
COPY assistant_* /

RUN chmod a+x /run.sh; chmod a+x /usr/bin/customtts.sh;\
 echo nameserver 1.1.1.1 > /etc/resolv.conf; apt-get update;\
 apt-get install -y mpg123; apt-get clean all

ENTRYPOINT [ "/run.sh" ]
