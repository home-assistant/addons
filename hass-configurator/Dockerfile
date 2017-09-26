ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache python3 git \
&& pip3 install GitPython

# Copy data
COPY configurator.py /
RUN chmod a+x /configurator.py

CMD ["python3", "/configurator.py", "/data/options.json"]
