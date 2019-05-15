FROM python:3.7.2-slim

ENV INSTALL_PATH /docker-robot
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY requirements.txt requirements.txt
COPY tests $INSTALL_PATH/tests
RUN apt update
RUN apt install git -y
RUN apt install python3-pip libcurl4-gnutls-dev -y
RUN pip3 install -r requirements.txt 

COPY . .

CMD ["robot","/docker-robot/tests/onboard_to_sonata.robot"]   
