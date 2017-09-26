ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache jq curl

# Copy data
COPY *.sh /
COPY config /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
