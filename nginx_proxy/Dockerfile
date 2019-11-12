ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
RUN apk add --no-cache nginx openssl curl

# Copy data
COPY data/run.sh /
COPY data/nginx.conf /etc/
COPY data/v3_ca /

CMD [ "/run.sh" ]
