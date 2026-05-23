ARG BUILD_FROM
FROM ${BUILD_FROM}

USER root

# jq is needed to read /data/options.json (Stirling image has no bashio)
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

# Redirect Stirling's runtime dirs into /data, which HA persists across
# restarts AND addon updates. (tessdata is left in place so bundled OCR works.)
RUN rm -rf /configs /logs /customFiles /pipeline \
    && ln -s /data/configs     /configs \
    && ln -s /data/logs        /logs \
    && ln -s /data/customFiles /customFiles \
    && ln -s /data/pipeline    /pipeline

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT []
CMD [ "/run.sh" ]