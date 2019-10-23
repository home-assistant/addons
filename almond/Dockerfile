ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install Alomond requirements
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        nodejs \
        yarnpkg \
    && rm -rf /var/lib/apt/lists/*


# Install Almond
ARG ALMOND_VERSION
WORKDIR /opt/almond
RUN git clone https://github.com/stanford-oval/almond-server . \
    && git checkout ${ALMOND_VERSION} \
    && rm -fr .git \
    && yarn \
    && rm -fr /root/.cache

ENV THINGENGINE_HOME=/data/almond-server
COPY data/run.sh /

CMD ["/run.sh"]