ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache jq samba-server samba-common-tools

# Copy data
COPY run.sh /
COPY smb.conf /etc/

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
