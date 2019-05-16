FROM ubuntu:18.04

ENV INSTALL_PATH /docker-robot
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY requirements.txt requirements.txt

ENV LANG C.UTF-8
RUN apt-get update \
  && apt-get install -y python3-pip python3-dev libcurl4-gnutls-dev librtmp-dev git \
  
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip
RUN pip3 install pycurl    
RUN pip3 install -r requirements.txt 

CMD /bin/bash