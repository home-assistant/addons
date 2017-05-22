FROM %%BASE_IMAGE%%

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache tzdata jq samba-server samba-common-tools

# Copy data
COPY run.sh /
COPY smb.conf /etc/

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
