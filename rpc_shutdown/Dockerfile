ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache samba-common-tools samba-common

# Copy data
COPY data/run.sh /

CMD [ "/run.sh" ]
