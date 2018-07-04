ARG BUILD_FROM
FROM $BUILD_FROM

# Copy data
COPY run.sh /
COPY mosquitto.conf /etc/
COPY customtts.sh /usr/bin

RUN chmod a+x /run.sh \
    && curl -L -o /assistant_Hass_de.zip https://s3.amazonaws.com/hassio-addons-data/assistant_Hass_de.zip \
    && curl -L -o /assistant_Hass_en.zip https://s3.amazonaws.com/hassio-addons-data/assistant_Hass_en.zip \
    && curl -L -o /assistant_Hass_fr.zip https://s3.amazonaws.com/hassio-addons-data/assistant_Hass_fr.zip \
    && chmod a+x /usr/bin/customtts.sh \
    && apt-get update \
    && (apt-get install -y mpg123 snips-asr-injection; exit 0) \
    && apt-get clean all

ENTRYPOINT [ "/run.sh" ]
