FROM debian
LABEL maintainer="Felipe Vicens felipevicens@atos.net, Santiago Rodriguez srodriguez@optaresolutions.com"
RUN apt-get update && \
    apt-get install -y libssl-dev sshpass \
                       && rm -rf /var/lib/apt/lists/*

ENV PROBE "services-check"
ENV USER ""
ENV PASS ""
ENV SERVICES ""

ADD entrypoint.sh /app/
ADD config.cfg /app/
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT [ "/app/entrypoint.sh" ]
