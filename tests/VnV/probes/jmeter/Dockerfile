# 1
FROM alpine:3.6
# 2
LABEL maintainer="Aureliano Sinatra <aureliano.sinatra@eglobalmark.com>"
ENV IP ""
ENV PORT ""
# 3 
ARG JMETER_VERSION="3.3"
# 4
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN  ${JMETER_HOME}/bin
ENV MIRROR_HOST https://archive.apache.org/dist/jmeter
ENV JMETER_DOWNLOAD_URL ${MIRROR_HOST}/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV JMETER_PLUGINS_DOWNLOAD_URL http://repo1.maven.org/maven2/kg/apc
ENV JMETER_PLUGINS_FOLDER ${JMETER_HOME}/lib/ext/
# 5
RUN    apk update \
	&& apk upgrade \
	&& apk add ca-certificates \
	&& update-ca-certificates \
    && apk add --update openjdk8-jre tzdata curl unzip bash \
    && cp /usr/share/zoneinfo/Europe/Rome /etc/localtime \
    && echo "Europe/Rome" >  /etc/timezone \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& rm -rf /tmp/dependencies
# 6
RUN curl -L --silent ${JMETER_PLUGINS_DOWNLOAD_URL}/jmeter-plugins-dummy/0.2/jmeter-plugins-dummy-0.2.jar -o ${JMETER_PLUGINS_FOLDER}/jmeter-plugins-dummy-0.2.jar
RUN curl -L --silent ${JMETER_PLUGINS_DOWNLOAD_URL}/jmeter-plugins-cmn-jmeter/0.5/jmeter-plugins-cmn-jmeter-0.5.jar -o ${JMETER_PLUGINS_FOLDER}/jmeter-plugins-cmn-jmeter-0.5.jar
RUN curl -L --silent https://github.com/emqx/mqtt-jmeter/raw/master/Download/v1.0.1/mqtt-xmeter-jar-with-dependencies.jar -o ${JMETER_PLUGINS_FOLDER}/mqtt-xmeter-jar-with-dependencies.jar

# 7
ENV PATH $PATH:$JMETER_BIN

# 8
RUN mkdir /app/
RUN mkdir /app/results/

ADD jmeter.properties $JMETER_BIN
ADD entrypoint.sh /app/
ADD config.cfg /app/
ADD input_simulator.jmx /app/
RUN chmod +x /app/entrypoint.sh
#9
WORKDIR ${JMETER_HOME}

#10
ENTRYPOINT ["/app/entrypoint.sh"]
