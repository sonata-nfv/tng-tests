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

subscribed=false

START=$(date +%s)
echo "Start: $START"

while true
do
    NOW=$(date +%s)
    echo "Time is now: $NOW"
    
    if [[ "$subscribed" == false ]]; then
        echo "shell before subscribe"
        mqtt-bench subscribe --host $IP --port $PORT --topic $TOPIC --qos $QOS --interval $INTERVAL --file $RESULTS_FILE
        echo "shell subscribed!"
        subscribed=true
    fi

	DIFF=$(( $NOW - $START ))
	echo "It took $DIFF seconds"
    
    sleep 1
    if [ "$DIFF" -ge $INTERVAL ]
    then
        echo "Bye bye!"
        echo "probe closed output redirect to $RESULTS_FILE"
        exit 0
    fi
done

