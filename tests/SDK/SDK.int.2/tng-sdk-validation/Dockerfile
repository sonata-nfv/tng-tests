#  Copyright (c) 2015 SONATA-NFV, 5GTANGO, UBIWHERE, QUOBIS SL.
# ALL RIGHTS RESERVED.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Neither the name of the SONATA-NFV, 5GTANGO, UBIWHERE, QUOBIS SL.
# nor the names of its contributors may be used to endorse or promote
# products derived from this software without specific prior written
# permission.
#
# This work has been performed in the framework of the SONATA project,
# funded by the European Commission under Grant number 671517 through
# the Horizon 2020 and 5G-PPP programmes. The authors would like to
# acknowledge the contributions of their colleagues of the SONATA
# partner consortium (www.sonata-nfv.eu).
#
# This work has also been performed in the framework of the 5GTANGO project,
# funded by the European Commission under Grant number 761493 through
# the Horizon 2020 and 5G-PPP programmes. The authors would like to
# acknowledge the contributions of their colleagues of the SONATA
# partner consortium (www.5gtango.eu).
FROM python:3.6-alpine
#FROM python:3.6.5-slim-jessie
MAINTAINER 5GTANGO

# install git
RUN apk update && apk upgrade && apk add --no-cache bash git 

RUN pip install pycodestyle

# install tng-sdk-project first
#WORKDIR /opt
RUN git clone https://github.com/sonata-nfv/tng-sdk-project.git
WORKDIR tng-sdk-project
RUN ls -hall
RUN pip install -r requirements.txt
RUN python setup.py install

ADD . /tng-sdk-validation

WORKDIR /tng-sdk-validation

RUN pip install -r requirements.txt
RUN python setup.py install

# This command leaves the tng-sdk-validate tool running in API mode
# Listening at por 5001
#RUN tng-sdk-validate --api 
