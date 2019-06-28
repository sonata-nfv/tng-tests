FROM python:3.7.2-slim

ENV INSTALL_PATH /docker-robot
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY requirements.txt requirements.txt
RUN apt update
RUN apt install -y python3-pip python3-dev libcurl4-gnutls-dev librtmp-dev git 
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
ENV OSM_HOSTNAME=10.30.0.170:9999

COPY . .

CMD /bin/bash