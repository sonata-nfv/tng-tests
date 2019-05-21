#!/bin/bash

source /app/config.cfg

jmeter -n -Jip=$IP -Jport=$PORT -t /app/input_simulator.jmx -o /app/results -l results.jtl 

