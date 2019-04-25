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

ping -c5 $EXTERNAL_IP >> $RESULTS_FILE ;