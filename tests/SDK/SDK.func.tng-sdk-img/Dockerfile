FROM python:3

ADD start.sh start.sh
RUN chmod +x start.sh

EXPOSE  8000
ENV SON_EMU_CMD ./start.sh

CMD /bin/bash
