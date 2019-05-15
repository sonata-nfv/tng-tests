FROM ubuntu:18.04

ENV INSTALL_PATH /docker-robot
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY requirements.txt requirements.txt
COPY tests $INSTALL_PATH/tests

ENV LANG C.UTF-8
RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip \
  && pip3 install -r requirements.txt 

CMD ["robot","/docker-robot/tests/onboard_to_sonata.robot"]   
