#!/bin/bash

echo "******* mqttprobe: starting entrypoint.sh ******"

source /mqtt-pubsub/config.cfg

echo "******* mqttprobe: creating folder /output/${PROBE}/${HOSTNAME} *******"

mkdir -p /output/${PROBE}/${HOSTNAME}

echo "ip = $IP"
echo "port = $PORT"
echo "rounds = $( eval echo {1..$ROUNDS} )"
echo "interval = $INTERVAL"
echo "BULK_DATA = $BULK_DATA"

echo "******* mqttprobe: executing benchmark *******"

sleep $INTERVAL 

for (( i=1; i<=$ROUNDS; c++ ))
do  
    echo "Executing round $i"
	export DATE=$(($(date +%s%N)/1000000))
	echo "mqtt-bench publish --host $IP --port $PORT --topic "WIMMS1/EM63/DATE"  --message $DATE 	 "
	mqtt-bench publish --host $IP --port $PORT --topic "WIMMS1/EM63/DATE"  --message $DATE 	 
	sleep $INTERVAL
done

echo "output redirect to: $RESULTS_FILE"
