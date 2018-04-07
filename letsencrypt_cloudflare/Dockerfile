ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
ARG DEHYDRATED_VERSION
ARG CLOUDFLARE_HOOK_SHA1

# Setup Base System
RUN apk add --no-cache git jq curl libressl python3 \
  && ln -s /usr/bin/python3 /usr/bin/python

# Setup dehydrated
RUN curl -s -o /usr/bin/dehydrated https://raw.githubusercontent.com/lukas2511/dehydrated/v$DEHYDRATED_VERSION/dehydrated \
  && chmod a+x /usr/bin/dehydrated

# Setup letsencrypt-cloudflare-hook
RUN git clone https://github.com/kappataumu/letsencrypt-cloudflare-hook /opt/letsencrypt-cloudflare-hook \
  && cd /opt/letsencrypt-cloudflare-hook \
  && git checkout $CLOUDFLARE_HOOK_SHA1 \
  && pip3 install -r requirements.txt

# Copy data
COPY *.sh /
RUN chmod a+x /*.sh

CMD [ "/run.sh" ]
