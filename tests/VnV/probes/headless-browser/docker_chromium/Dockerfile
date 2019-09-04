# Build the image (Local):
# docker build -t docker-chromium .
# Run the image:
# docker run -e WEB="https://rooms.quobis.com" -e CALLER="quobisqa3@quobis" -e PASSWORD="oWc0n2M84xt2" -e CALLED="quobisqa1" -e DURATION=10000 -e USER="apps" --privileged docker-chromium



# Dockerfile
FROM node:10.15.3-slim@sha256:88da5cd281ece24309c4e6fcce000a8001b17804e19f94a0439954568716a668
RUN apt-get update; apt-get clean
# Add a user for running applications.
RUN useradd apps
RUN mkdir -p /home/apps && chown -R -L apps:apps /home/apps

# Install wget.
RUN apt-get install -y wget

RUN  apt-get update \
     # Install latest chrome dev package, which installs the necessary libs to
     # make the bundled version of Chromium that Puppeteer installs work.
     && apt-get install -y wget --no-install-recommends \
     && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
     && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
     && apt-get update \
     && apt-get install -y google-chrome-unstable --no-install-recommends \
     && rm -rf /var/lib/apt/lists/* \
     && wget --quiet https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -O /usr/sbin/wait-for-it.sh \
     && chmod +x /usr/sbin/wait-for-it.sh

# Install Puppeteer under /node_modules so it's available system-wide
ADD package.json package-lock.json /
RUN npm install

RUN apt-get update \
    && apt-get install -y tcpdump

RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump

ENV PROBE "headless"
ENV WEB ""
ENV CALLER ""
ENV PASSWORD ""
ENV CALLED ""
ENV DURATION ""


EXPOSE 3000

WORKDIR /output/${PROBE}/$HOSTNAME
VOLUME /output/${PROBE}/$HOSTNAME

COPY app.js /
COPY config.cfg /
COPY entrypoint.sh /


RUN ["chmod", "777", "/entrypoint.sh"]
RUN ["chmod", "777", "/config.cfg"]
RUN ["chmod", "777", "/app.js"]


ENTRYPOINT ["/entrypoint.sh"]
