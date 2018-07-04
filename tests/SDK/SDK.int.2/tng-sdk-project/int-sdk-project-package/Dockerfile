FROM ubuntu:18.04

# install required packages
RUN apt-get clean
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y git python3 python3-setuptools
    
# install tng-sdk-project
RUN git clone https://github.com/sonata-nfv/tng-sdk-project.git
RUN cd tng-sdk-project && python3 setup.py develop & cd ..

# install tng-sdk-package
RUN git clone https://github.com/sonata-nfv/tng-sdk-package.git
RUN cd tng-sdk-package && python3 setup.py install & cd ..
