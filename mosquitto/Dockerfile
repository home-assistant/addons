FROM %%BASE_IMAGE%%

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache tzdata jq mosquitto

# Copy data
COPY run.sh /
COPY mosquitto.conf /etc/

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
