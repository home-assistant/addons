ARG BUILD_FROM
ARG BUILD_ARCH

FROM jhampdbre/${BUILD_ARCH}-nginx-116-modsecurity as build_modsecurity

FROM $BUILD_FROM

# Setup base
RUN apk add --no-cache \
    curl-dev \
    geoip \
    libmaxminddb-dev \
    libstdc++ \
    libxml2-dev \
    lmdb-dev \
    yajl \
    nginx \
    openssl \
    && mkdir /etc/nginx/modsec

# Copy owasp-modsecurity-crs and modsecurity from the build image
COPY --from=build_modsecurity /usr/local/modsecurity /usr/local/modsecurity
COPY --from=build_modsecurity /usr/local/owasp-modsecurity-crs /usr/local/owasp-modsecurity-crs
COPY --from=build_modsecurity /usr/lib/nginx/modules/ /usr/lib/nginx/modules/

# Copy data
COPY data/run.sh /
COPY data/nginx.conf /etc/
COPY data/modsec/ /etc/nginx/modsec/
COPY data/owasp/ /usr/local/owasp-modsecurity-crs/

CMD [ "/run.sh" ]
