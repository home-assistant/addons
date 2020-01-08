ARG BUILD_FROM
FROM $BUILD_FROM

# Copy data
COPY data/run.sh /
COPY data/mosquitto.conf /etc/
COPY data/customtts.sh /usr/bin
COPY data/snips-entrypoint.sh /

ARG BUILD_ARCH

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        apt-utils \
        dirmngr \
        gnupg-curl \
        mpg123 \
        supervisor \
        unzip \
    && rm -rf /var/lib/apt/lists/* \
    && if [ "$BUILD_ARCH" = "amd64" ]; \
        then \
            bash -c 'echo "deb https://debian.snips.ai/stretch stable main" > /etc/apt/sources.list.d/snips.list' \
            && apt-key adv --fetch-keys https://debian.snips.ai/5FFCD0DEB5BA45CD.pub; \
        else \
            bash -c 'echo "deb https://raspbian.snips.ai/stretch stable main" > /etc/apt/sources.list.d/snips.list' \
            && apt-key adv --fetch-keys https://raspbian.snips.ai/531DD1A7B702B14D.pub; \
        fi

ARG SNIPS_VERSION
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        snips-platform-voice=${SNIPS_VERSION} \
        snips-asr=${SNIPS_VERSION} \
        snips-injection=${SNIPS_VERSION} \
        snips-watch=${SNIPS_VERSION} \
        mosquitto \
        snips-audio-server=${SNIPS_VERSION} \
        snips-dialogue=${SNIPS_VERSION} \
        snips-hotword=${SNIPS_VERSION} \
        snips-nlu=${SNIPS_VERSION} \
        snips-tts=${SNIPS_VERSION} \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L -o /assistant_Hass_de.zip https://s3.amazonaws.com/hassio-addons-data/assistant_Hass_de.zip \
    && curl -L -o /assistant_Hass_en.zip https://s3.amazonaws.com/hassio-addons-data/assistant_Hass_en.zip \
    && curl -L -o /assistant_Hass_fr.zip https://s3.amazonaws.com/hassio-addons-data/assistant_Hass_fr.zip

ENTRYPOINT [ "/run.sh" ]
