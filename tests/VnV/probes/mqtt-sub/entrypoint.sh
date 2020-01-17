#!/bin/bash

echo "******* mqttsub: starting entrypoint.sh ******"

source /mqtt-pubsub/config.cfg

echo "******* mqttsub: creating folder /output/${PROBE}/${HOSTNAME} *******"

mkdir -p /output/${PROBE}/${HOSTNAME}

echo "ip = $IP"
echo "port = $PORT"
echo "interval = $INTERVAL"
echo "TOPIC = $TOPIC"
echo "QOS = $QOS"

echo "******* mqttsub: executing benchmark *******"

echo "Subscribing:   mqtt-bench subscribe --host $IP --port $PORT --topic $TOPIC --qos $QOS"

mqtt-bench subscribe --host $IP --port $PORT --topic $TOPIC --qos $QOS --interval $INTERVAL --file $RESULTS_FILE

echo "probe closed output redirect to $RESULTS_FILE"