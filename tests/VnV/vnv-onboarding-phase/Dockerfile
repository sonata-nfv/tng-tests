FROM ubuntu:18.04

ENV INSTALL_PATH /docker-robot
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY requirements.txt requirements.txt
COPY tests $INSTALL_PATH/tests

ENV LANG C.UTF-8
RUN apt-get update && apt-get install -y python python-dev python3.5 python3.5-dev python-pip virtualenv libssl-dev libpq-dev git build-essential libfontconfig1 libfontconfig1-dev
RUN pip install setuptools pip --upgrade --force-reinstall
RUN virtualenv /venv/testenv/ -p which python3.5
RUN pip3 install -r requirements.txt 

CMD ["robot","/docker-robot/tests/onboard_to_sonata.robot"]   
