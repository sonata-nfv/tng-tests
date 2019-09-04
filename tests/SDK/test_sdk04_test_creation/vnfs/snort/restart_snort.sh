#!/bin/bash

pkill snort
sleep 5

# run snort as background process
snort -i $IFIN:$IFOUT -D -k none -K ascii -l /snort-logs -A fast -c /etc/snort/snort.conf

echo "Snort VNF started ..."
