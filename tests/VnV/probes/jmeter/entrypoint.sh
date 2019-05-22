#!/bin/bash

source /app/config.cfg

jmeter -n -Jip=$IP -Jport=$PORT -t /app/input_simulator.jmx 

