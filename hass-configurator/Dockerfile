FROM %%BASE_IMAGE%%

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache python3 tzdata git \
&& pip3 install GitPython

# Copy data
COPY configurator.py run.sh /
RUN chmod a+x /configurator.py /run.sh

CMD ["/run.sh"]
