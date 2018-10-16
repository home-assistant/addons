ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
ARG HASSIO_PAM_VERSION
RUN apk add --no-cache \
        musl libcurl linux-pam curl samba-server samba-common-tools \
    && apk add --no-cache --virtual .build-dependencies \
        musl-dev curl-dev linux-pam-dev gcc git make \
    && git clone --depth 1 -b $HASSIO_PAM_VERSION https://github.com/home-assistant/hassio-auth-pam \
    && cd hassio-auth-pam \
    && make \
    && cp -f pam_hassio.so /lib/security/ \
    && apk del .build-dependencies \
    && rm -r /usr/src/hassio-auth-pam

# Copy data
COPY run.sh /
COPY smb.conf /etc/
COPY samba.pam /etc/pam.d/samba

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
