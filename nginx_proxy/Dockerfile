ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache nginx openssl

# Copy data
COPY run.sh /
COPY nginx.conf /etc/

CMD [ "/run.sh" ]
