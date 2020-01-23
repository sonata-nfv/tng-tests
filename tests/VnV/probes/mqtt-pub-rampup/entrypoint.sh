#!/bin/bash

echo "******* publisher: starting entrypoint.sh ******"

source /mqtt-publisher/config.cfg

echo "******* mqttprobe: creating folder /output/${PROBE}/${HOSTNAME} *******"

mkdir -p /output/${PROBE}/${HOSTNAME}

echo "mqtt-publisher ip = $IP"
echo "mqtt-publisher port = $PORT"
echo "mqtt-publisher rounds = $( eval echo {1..$ROUNDS} )"
echo "mqtt-publisher interval = $INTERVAL"
echo "mqtt-publisher TOPIC = $TOPIC"
echo "mqtt-publisher CLIENTS = $CLIENTS"
echo "mqtt-publisher COUNT = $COUNT"

echo "******* publisher: executing benchmark *******"

for i in $( eval echo {1..$ROUNDS} )
do  
    echo "Executing round $i"
	echo "mqtt-bench publish --host $IP --port $PORT --topic $TOPIC --thread-num $(( $CLIENTS * i )) --publish-num $COUNT --message $(($(date +%s%N)/1000000)) 	 "
	mqtt-bench publish --host $IP --port $PORT --topic $TOPIC  --thread-num $(( $CLIENTS * i )) --publish-num $COUNT --message $(($(date +%s%N)/1000000))	 
	sleep $INTERVAL
done

echo "probe closed output redirect to $RESULTS_FILE"