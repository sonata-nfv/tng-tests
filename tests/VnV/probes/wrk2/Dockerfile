FROM debian
LABEL maintainer="Felipe Vicens felipevicens@atos.net, Santiago Rodriguez srodriguez@optaresolutions.com"
RUN apt-get update && \
    apt-get install -y build-essential \
                       libssl-dev \
                       git \
                       zlib1g \
                       zlib1g-dev \
                       && apt-get remove --purge --auto-remove \
                       && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone https://github.com/giltene/wrk2.git
WORKDIR /app/wrk2
RUN make

FROM debian
LABEL maintainer="Felipe Vicens felipevicens@atos.net"
RUN apt-get update && \
    apt-get install -y libssl-dev jq netcat && \
    rm -rf /var/lib/apt/lists/*

ENV PROBE "wrk2"
ENV PROTOCOL "http"
ENV EXTERNAL_IP ""
ENV PORT "80"
ENV URL_PATH ""
ENV CONNECTIONS "10"
ENV DURATION "30s"
ENV THREADS "2"
ENV HEADER ""
ENV TIMEOUT "20s"
ENV RATE "200"
ENV PROXY="no"
ENV PROXY_IP ""

COPY --from=0 /app/wrk2/wrk /usr/local/bin/
ADD config.cfg /app/
ADD result.lua /app/
ADD result_proxy.lua /app/
ADD entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT [ "/app/entrypoint.sh" ]
