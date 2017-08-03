FROM %%BASE_IMAGE%%

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache \
    jq openssh vim curl nano git mosquitto-clients bluez

# Copy data
COPY run.sh /
COPY motd /etc/
COPY hassio /usr/bin/

RUN chmod a+x /run.sh /usr/bin/hassio

CMD [ "/run.sh" ]
