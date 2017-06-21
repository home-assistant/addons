FROM %%BASE_IMAGE%%

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache jq dnsmasq

# Copy data
COPY run.sh /
COPY dnsmasq.conf /etc/

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
