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

SUBSCRIBED = false

START=$(date +%s)

while true
do
    NOW=`date '+%H%M'`
    echo "Time is now: $NOW"
    
    if [ $SUBSCRIBED = false]
    then
        mqtt-bench subscribe --host $IP --port $PORT --topic $TOPIC --qos $QOS --interval $INTERVAL --file $RESULTS_FILE
    fi

	END=$(date +%s)
	DIFF=$(( $END - $START ))
	echo "It took $DIFF seconds"
    
    sleep 1
    if [ $DIFF -le $INTERVAL ]
    then
        echo "Bye bye!"
        echo "probe closed output redirect to $RESULTS_FILE"
        exit 0
    fi
done

