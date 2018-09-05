ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
RUN apk add --no-cache \
        jq gcc \
        libffi-dev libressl-dev musl-dev \
    && pip3 install --no-cache --upgrade pip

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
