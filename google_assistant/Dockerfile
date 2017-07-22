#armhf:FROM multiarch/debian-debootstrap:armhf-stretch
#amd64:FROM multiarch/debian-debootstrap:amd64-stretch

# Install packages
RUN apt-get update \
    && apt-get install -y jq tzdata python3 python3-dev python3-pip \
        python3-six python3-pyasn1 libportaudio2 alsa-utils \
    && pip3 install google-assistant-library google-auth requests_oauthlib cherrypy \
    && apt-get remove -y --purge python3-pip python3-dev \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Copy data
COPY run.sh /
COPY *.py /
COPY asoundrc /root/.asoundrc

RUN chmod a+x /run.sh

ENTRYPOINT [ "/run.sh" ]
