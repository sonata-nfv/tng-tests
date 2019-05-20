#!/bin/bash

source /app/config.cfg

jmeter -n -Jip=$IP -Jport=$PORT -t /app/input_simulator.jmx -l results.jtl -j jmeter.log

# Keep entrypoint simple: we must pass the standard JMeter arguments
