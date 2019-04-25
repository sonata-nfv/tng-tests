#!/bin/bash

source /app/config.cfg

mkdir -p /output/${PROBE}/${HOSTNAME}

echo "Telnet configuration: "
echo " - Results file: $RESULTS_FILE"
echo "External IP: "$EXTERNAL_IP
echo "Port: "$PORT

if  [ -z $EXTERNAL_IP ]; then
  echo "Invalid external IP" > $RESULTS_FILE
  exit 1
else
  opt1="$EXTERNAL_IP"
fi

telnet $EXTERNAL_IP $PORT >> $RESULTS_FILE ;