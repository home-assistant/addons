ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

# Install Git to enable download of fresh source every time add-on is run
RUN apk add --no-cache git

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
