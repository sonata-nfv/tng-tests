#!/bin/bash

echo "******* mqttprobe: starting entrypoint.sh ******"

source /mqtt-pubsub/config.cfg

echo "******* mqttprobe: creating folder /output/${PROBE}/${HOSTNAME} *******"

mkdir -p /output/${PROBE}/${HOSTNAME}

echo "mqtt-pubsub ip = $IP"
echo "mqtt-pubsub port = $PORT"
echo "mqtt-pubsub rounds = $( eval echo {1..$ROUNDS} )"
echo "mqtt-pubsub interval = $INTERVAL"
echo "mqtt-pubsub TOPIC = $TOPIC"
echo "mqtt-pubsub CLIENTS = $CLIENTS"
echo "mqtt-pubsub COUNT = $COUNT"

echo "******* mqttprobe: executing benchmark *******"

sleep $INTERVAL 

for i in $( eval echo {1..$ROUNDS} )
do  
    echo "Executing round $i"
	export DATE=$(($(date +%s%N)/1000000))
	echo "mqtt-bench publish --host $IP --port $PORT --topic $TOPIC  --message $DATE 	 "
	mqtt-bench publish --host $IP --port $PORT --topic $TOPIC  --thread-num $CLIENTS --publish-num $COUNT --message $DATE 	 
	sleep $INTERVAL
done

echo "probe closed output redirect to $RESULTS_FILE"