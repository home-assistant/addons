FROM %%BASE_IMAGE%%

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache tzdata jq bluez git

# Install firmware
RUN git clone --depth 1 https://github.com/RPi-Distro/firmware-nonfree /tmp/firmware \
    && mkdir -p /lib/firmware/brcm \
    && cp -f /tmp/firmware/brcm80211/brcm/* /lib/firmware/brcm/ \
    && rm -rf /tmp/firmware
    
# Copy firmware
COPY BCM43430A1.hcd /lib/firmware/brcm/

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
