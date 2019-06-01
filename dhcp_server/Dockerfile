ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache dhcp

# Copy data
COPY run.sh /

CMD [ "/run.sh" ]
