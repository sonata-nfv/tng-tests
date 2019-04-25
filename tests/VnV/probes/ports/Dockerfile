FROM ubuntu
LABEL maintainer="AR, ALB, Optare"
RUN apt-get update && \
    apt-get install -y telnet \
                       && apt-get remove --purge --auto-remove \
                       && rm -rf /var/lib/apt/lists/*

ENV PROBE "telnet"
ENV EXTERNAL_IP ""
ENV PORT ""

WORKDIR /app
ADD config.cfg /app
ADD entrypoint.sh /app
RUN ["chmod", "+x", "/app/entrypoint.sh"]

ENTRYPOINT [ "/app/entrypoint.sh" ]
