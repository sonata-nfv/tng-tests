#!/bin/bash
source /mqtt-test/config.cfg

echo "ip = $IP"
echo "port = $PORT"
echo "packet size = $SIZE"
echo "messages per client = $COUNT"
echo "clients = $CLIENTS"


mqtt-benchmark --broker tcp://$IP:$PORT --count $COUNT --size $SIZE --clients $CLIENTS --qos 2 --format json --username $USERNAME --password $PASSWORD

