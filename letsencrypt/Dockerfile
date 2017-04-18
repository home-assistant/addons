FROM %%BASE_IMAGE%%

# Add version
ENV VERSION %%VERSION%%
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache jq git python3

# Copy data
COPY run.sh /
RUN chmod 775 /run.sh

CMD [ "/run.sh" ]
