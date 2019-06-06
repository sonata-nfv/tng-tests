FROM python:3.7.2-slim

ENV INSTALL_PATH /mqtt-test
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY requirements.txt requirements.txt
RUN apt update
RUN apt install -y python3-pip python3-dev libcurl4-gnutls-dev librtmp-dev git 
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

COPY . .

ENTRYPOINT [ "/app/entrypoint.sh" ]