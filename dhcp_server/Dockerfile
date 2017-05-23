FROM %%BASE_IMAGE%%

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache tzdata jq dhcp

# Copy data
COPY run.sh /
COPY dhcpd.conf /etc/

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
