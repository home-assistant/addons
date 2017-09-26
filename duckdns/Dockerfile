ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache jq curl libressl \
  && curl -s -o /usr/bin/dehydrated https://raw.githubusercontent.com/lukas2511/dehydrated/v0.4.0/dehydrated \
  && chmod a+x /usr/bin/dehydrated

# Copy data
COPY *.sh /
RUN chmod a+x /*.sh

CMD [ "/run.sh" ]
