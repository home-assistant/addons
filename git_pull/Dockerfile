ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
RUN apk add --no-cache jq curl git openssh-client rsync

# Copy data
COPY data/run.sh /

CMD [ "/run.sh" ]
