#!/bin/bash

source /config.cfg


mkdir -m 777 -p /output/${PROBE}/$HOSTNAME
#docker run -e WEB="https://rooms.quobis.com" -e CALLER="quobisqa3@quobis" -e PASSWORD="oWc0n2M84xt2" -e CALLED="quobisqa1" -e DURATION=10000 --user apps --privileged docker-chromium

echo "CALL CONFIGURATION"
echo "Docker User: "$USER
echo "Web: "$WEB
echo "User Caller: "$CALLER
echo "User Called: "$CALLED
echo "Duration: "$DURATION




echo "Result file: /output/${PROBE}/$HOSTNAME/results.log"
tcpdump -i eth0 udp -vv >> "/output/${PROBE}/$HOSTNAME/aux.log" &

su -c "sed '/rooms\|blah/!d' '/output/${PROBE}/$HOSTNAME/aux.log' > '/output/${PROBE}/$HOSTNAME/results.log'" apps

echo -e "PUPPETEER LOGS"  >> "/output/${PROBE}/$HOSTNAME/results.log"
su -c "node /app.js  >> '/output/${PROBE}/$HOSTNAME/results.log'" apps
echo -e " \n"  >> "/output/${PROBE}/$HOSTNAME/results.log"

echo -e "CALL CONFIGURATION"  >> "/output/${PROBE}/$HOSTNAME/results.log"
echo "Docker User: "$USER  >> "/output/${PROBE}/$HOSTNAME/results.log"
echo "Web: "$WEB  >> "/output/${PROBE}/$HOSTNAME/results.log"
echo "Caller user: "$CALLER  >> "/output/${PROBE}/$HOSTNAME/results.log"
echo "Called user: "$CALLED  >> "/output/${PROBE}/$HOSTNAME/results.log"
echo "Duration: "$DURATION  >> "/output/${PROBE}/$HOSTNAME/results.log"
echo -e " \n"  >> "/output/${PROBE}/$HOSTNAME/results.log"
echo -e "TCPDUMP LOGS"  >> "/output/${PROBE}/$HOSTNAME/results.log"
sed '/rooms\|blah/!d' "/output/${PROBE}/$HOSTNAME/aux.log" >> "/output/${PROBE}/$HOSTNAME/results.log"
