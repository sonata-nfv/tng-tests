FROM alpine

LABEL maintainer="Aureliano Sinatra <sinaure@gmail.com>"

ENV PROBE "mqttprobe2"

RUN apk add --update libev-dev git

RUN git config --global http.sslVerify false
RUN git clone https://github.com/useyourfeelings/mqtt_turtle.git
RUN cd mqtt_turtle && \
	python3 setup.py build 
ADD entrypoint.sh /app/
ADD config.cfg /app/

ENTRYPOINT [ "/app/entrypoint.sh" ]