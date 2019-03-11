ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
ARG CERTBOT_VERSION
RUN pip3 install --no-cache-dir certbot==${CERTBOT_VERSION}

# Copy data
COPY run.sh /

CMD [ "/run.sh" ]
