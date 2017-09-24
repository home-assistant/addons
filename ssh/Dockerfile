ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache jq openssh vim curl nano git mosquitto-clients

# Copy data
COPY run.sh /
COPY motd /etc/
COPY hassio /usr/bin/

RUN chmod a+x /run.sh /usr/bin/hassio

CMD [ "/run.sh" ]
