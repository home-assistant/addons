#armhf:FROM snipsdocker/platform:arm-0.4.9
#amd64:FROM snipsdocker/platform:x86-0.4.9

# Copy data
COPY run.sh /
COPY mosquitto.conf /etc/
COPY asoundrc /root/.asoundrc

RUN chmod a+x /run.sh

ENTRYPOINT [ "/run.sh" ]
