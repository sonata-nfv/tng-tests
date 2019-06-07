FROM golang:1.11

LABEL maintainer="Aureliano Sinatra <sinaure@gmail.com>"

ENV INSTALL_PATH /mqtt-test
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH


RUN git config --global http.sslVerify false
RUN go get github.com/krylovsk/mqtt-benchmark

ADD entrypoint.sh $INSTALL_PATH
ADD config.cfg $INSTALL_PATH

ENTRYPOINT [ "/mqtt-test/entrypoint.sh" ]