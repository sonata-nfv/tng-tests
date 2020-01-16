#!/bin/bash

echo "******* mqttprobe: starting entrypoint.sh ******"

source /mqtt-pubsub/config.cfg

echo "******* mqttprobe: creating folder /output/${PROBE}/${HOSTNAME} *******"

mkdir -p /output/${PROBE}/${HOSTNAME}

echo "ip = $IP"
echo "port = $PORT"
echo "interval = $INTERVAL"
echo "TOPIC = $TOPIC"

echo "******* mqttprobe: executing benchmark *******"

mqtt-bench subscribe --host $IP --port $PORT --topic $TOPIC

echo "output redirect to: $RESULTS_FILE"
