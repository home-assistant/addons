FROM python:3.9-bullseye as build

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
      python3-dev python3-venv build-essential

WORKDIR /app

COPY src/ ./src/

# Install faster-whisper
RUN python3 -m venv .venv && \
    .venv/bin/pip3 install --upgrade pip && \
    .venv/bin/pip3 install --upgrade wheel setuptools

RUN .venv/bin/pip3 install src/faster-whisper/src
RUN .venv/bin/pip3 install -r src/requirements.txt

# -----------------------------------------------------------------------------

FROM python:3.9-slim-bullseye as run

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
      wget jq

COPY --from=build /app/.venv/ /app/.venv/
COPY src/ /app/src/

COPY run.sh /app/
RUN chmod a+x /app/run.sh

# TCP
EXPOSE 10300

ENTRYPOINT ["bash", "/app/run.sh"]
