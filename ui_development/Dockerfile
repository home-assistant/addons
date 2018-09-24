ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
RUN apk add --no-cache socat

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
