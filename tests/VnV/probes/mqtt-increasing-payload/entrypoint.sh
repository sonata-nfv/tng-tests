#!/bin/bash

echo "******* mqttprobe: starting entrypoint.sh ******"

set -e
source /app/config.cfg

echo "******* mqttprobe: creating folder /output/${PROBE}/${HOSTNAME} *******"

mkdir -p /output/${PROBE}/${HOSTNAME}

echo "ip = $IP"
echo "port = $PORT"
echo "packet size = $SIZE"
echo "messages per client = $COUNT"
echo "clients = $CLIENTS"
echo "rounds = $( eval echo {1..$ROUNDS} )"
echo "qos = $QOS"
echo "interval = $INTERVAL"

echo "******* mqttprobe: executing benchmark *******"

for i in $( eval echo {1..$ROUNDS} )
do
    echo "Executing round $i"
    echo "mqtt-benchmark --broker tcp://$IP:$PORT --count $COUNT --size $(( $SIZE * i )) --clients $CLIENTS --qos $QOS --format json"
    mqtt-benchmark --broker tcp://$IP:$PORT --count $COUNT --size $(( $SIZE * i )) --clients $CLIENTS --qos $QOS --format json --quiet >> $RESULTS_FILE
	sleep $INTERVAL
done

echo "output redirect to: $RESULTS_FILE"
