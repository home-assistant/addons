ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
ARG CERTBOT_VERSION
RUN apk add --no-cache \
        openssl libffi musl libstdc++ \
    && apk add --no-cache --virtual .build-dependencies \
        g++ musl-dev openssl-dev libffi-dev \
    && pip3 install --no-cache-dir certbot==${CERTBOT_VERSION} \
    && apk del .build-dependencies

# Copy data
COPY run.sh /

CMD [ "/run.sh" ]
