ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
RUN apk add --no-cache nginx openssl

# Copy data
COPY data/run.sh /
COPY data/nginx.conf /etc/
COPY data/mime.types /etc/

CMD [ "/run.sh" ]
