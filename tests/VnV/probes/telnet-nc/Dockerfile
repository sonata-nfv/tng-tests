FROM ubuntu
LABEL maintainer="Optare"
RUN apt-get update && \
    apt-get install -y netcat python-pip\
    && apt-get remove --purge --auto-remove \
    && rm -rf /var/lib/apt/lists/*

RUN pip install docker-compose

ENV PROBE "netcat"
ENV EXTERNAL_IP ""
ENV PORT ""

WORKDIR /app
ADD config.cfg /app
ADD entrypoint.sh /app
RUN ["chmod", "+x", "/app/entrypoint.sh"]

ENTRYPOINT [ "/app/entrypoint.sh" ]
