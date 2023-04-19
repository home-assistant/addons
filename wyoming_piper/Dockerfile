FROM python:3.9-bullseye as build

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
      python3-venv wget

WORKDIR /app

# Download piper for CPU architecture
RUN export arch="$(uname -m)" && \
    if [ "${arch}" = 'x86_64' ]; then export arch='amd64'; \
    elif [ "${arch}" = 'aarch64' ]; then export arch='arm64'; \
    else echo "Unsupported architecture: ${arch}"; exit 1; fi && \
    wget -O- "https://github.com/rhasspy/piper/releases/download/v0.0.2/piper_${arch}.tar.gz" | \
    tar -xzf -

RUN mkdir -p ./src && mv ./piper/* ./src/ && rm -rf ./piper

COPY src/requirements.txt ./src/

# Install faster-whisper
RUN python3 -m venv .venv && \
    .venv/bin/pip3 install --upgrade pip && \
    .venv/bin/pip3 install --upgrade wheel setuptools

RUN .venv/bin/pip3 install -r src/requirements.txt

# -----------------------------------------------------------------------------

FROM python:3.9-slim-bullseye

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
      wget jq

COPY --from=build /app/ /app/

COPY src/piper_server.py /app/src/

COPY run.sh /app/
RUN chmod a+x /app/run.sh

# TCP
EXPOSE 10200

ENTRYPOINT ["bash", "/app/run.sh"]
