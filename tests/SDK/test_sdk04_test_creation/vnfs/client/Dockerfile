FROM ubuntu:trusty
MAINTAINER askhat.nuriddinov@ugent.be

RUN     apt-get update && apt-get install -y \
        net-tools \
        iproute \
        inetutils-ping \
        curl

ENV VIM_EMU_CMD "echo VNF tester is ready"

CMD /bin/bash
