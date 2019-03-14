ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache \
        curl samba-server samba-common-tools

# Copy data
COPY run.sh /
COPY smb.conf /etc/

CMD [ "/run.sh" ]
