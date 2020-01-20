#!/bin/bash

echo "******* mqttsubscriber: starting entrypoint.sh ******"

source /mqtt-subscriber/config.cfg

echo "******* mqttsubscriber: creating folder /output/${PROBE}/${HOSTNAME} *******"

mkdir -p /output/${PROBE}/${HOSTNAME}

echo "mqttsubscriber ip = $IP"
echo "mqttsubscriber port = $PORT"
echo "mqttsubscriber interval = $INTERVAL"
echo "mqttsubscriber TOPIC = $TOPIC"
echo "mqttsubscriber QOS = $QOS"

echo "******* mqttsub: executing benchmark *******"

echo "Subscribing:   mqtt-bench subscribe --host $IP --port $PORT --topic $TOPIC --qos $QOS"

mqtt-bench subscribe --host $IP --port $PORT --topic $TOPIC --qos $QOS --interval $INTERVAL --file $RESULTS_FILE

echo "probe closed output redirect to $RESULTS_FILE"