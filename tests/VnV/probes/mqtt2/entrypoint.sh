#!/bin/bash

source /app/config.cfg
mkdir -p /output/${PROBE}/${HOSTNAME}

echo "ip = $IP"
echo "port = $PORT"
echo "packet size = $SIZE"
echo "messages per client = $COUNT"
echo "clients = $CLIENTS"


mqtt_turtle_sender -h $IP -p $PORT -c $CLIENTS -m $COUNT -n egm_benchmark -t amqp.topic -i 7 -P 100 -M $MESSAGE  >  $RESULTS_FILE

echo "output redirect to: $RESULTS_FILE"
