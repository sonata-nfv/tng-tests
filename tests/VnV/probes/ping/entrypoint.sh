#!/bin/bash

source /app/config.cfg

mkdir -p /output/${PROBE}/${HOSTNAME}

echo "Ping probe configuration: "
echo " - Results file: $RESULTS_FILE"
echo " - External IP: $EXTERNAL_IP"

if  [ -z $EXTERNAL_IP ]; then
  echo "Invalid external IP" > $RESULTS_FILE
  exit 1
fi

{ echo "ping starts:"; date +%s%N; } | sed ':a;N;s/\n/ /;ba' >> $RESULTS_FILE

ping -c5 $EXTERNAL_IP >> $RESULTS_FILE ;

{ echo "ping ends:"; date +%s%N; } | sed ':a;N;s/\n/ /;ba' >> $RESULTS_FILE
