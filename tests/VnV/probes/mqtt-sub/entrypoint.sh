#!/bin/bash

echo "******* mqttprobe: starting entrypoint.sh ******"

source /mqtt-pubsub/config.cfg

echo "******* mqttprobe: creating folder /output/${PROBE}/${HOSTNAME} *******"

mkdir -p /output/${PROBE}/${HOSTNAME}

echo "ip = $IP"
echo "port = $PORT"
echo "interval = $INTERVAL"
echo "TOPIC = $TOPIC"
echo "QOS = $QOS"

echo "******* mqttprobe: executing benchmark *******"

echo "Subscribing:   mqtt-bench subscribe --host $IP --port $PORT --topic $TOPIC --qos $QOS"
mqtt-bench subscribe --host $IP --port $PORT --topic $TOPIC --qos $QOS >> $RESULTS_FILE

echo "output redirect to: $RESULTS_FILE"
