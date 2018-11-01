ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache \
        socat curl samba-server samba-common-tools

# Copy data
COPY run.sh /
COPY smb.conf /etc/
COPY userdb.sh /bin/
COPY userdb.html /usr/share/

RUN chmod a+x /run.sh /bin/userdb.sh

CMD [ "/run.sh" ]
