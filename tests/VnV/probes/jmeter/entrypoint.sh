#!/bin/bash

source /app/config.cfg

echo "threads = $THREADS"
echo "DURATION = $DURATION"
echo "RAMP_TIME = $RAMP_TIME"
jmeter -n -Jip=$IP -Jport=$PORT -Jthreads=$THREADS -Jduration=$DURATION -Jramp_time=$RAMP_TIME -t /app/input_simulator.jmx -l /app/results/out.jtl

