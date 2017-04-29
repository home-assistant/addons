FROM %%BASE_IMAGE%%

# Add version
ENV VERSION %%VERSION%%
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache jq mosquitto

# Copy data
COPY run.sh /
COPY mosquitto.conf /etc/

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
