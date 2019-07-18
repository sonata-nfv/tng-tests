FROM ubuntu:trusty

RUN apt-get update && apt-get install -y \
    net-tools \
    iproute \
    inetutils-ping \
    python

ADD app.py app.py
RUN chmod +x app.py

ENV VIM_EMU_CMD "./app.py &"
CMD /bin/bash
