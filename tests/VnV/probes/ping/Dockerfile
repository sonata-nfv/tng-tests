FROM debian
LABEL maintainer="Felipe Vicens felipevicens@atos.net, Santiago Rodriguez srodriguez@optaresolutions.com"
RUN apt-get update && \
    apt-get install -y libssl-dev \
                       && rm -rf /var/lib/apt/lists/*

ENV PROBE "ping"
ENV EXTERNAL_IP ""

ADD entrypoint.sh /app/
ADD config.cfg /app/
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT [ "/app/entrypoint.sh" ]
