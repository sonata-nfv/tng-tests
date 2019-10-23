FROM haproxy:latest
MAINTAINER askhat.nuriddinov@ugent.be

RUN     apt-get update && apt-get install -y \
        net-tools \
        iproute2 \
        inetutils-ping \
        socat \
        curl \
        vim

COPY haproxy.cfg haproxy.cfg

COPY add-server.sh add-server
RUN chmod a+x add-server

COPY remove-server.sh remove-server
RUN chmod a+x remove-server

ENV VIM_EMU_CMD "haproxy -f haproxy.cfg &"

CMD /bin/bash
