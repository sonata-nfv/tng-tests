# Telnet Probe

This probe executes a netcat against an IP/PORT. It generates a results.log file in /output that can be accessed via docker volume


| Parameter | Mandatory |
|---|---|
|EXTERNAL_IP| Yes|
|PORT|Yes|

## Docker execution example

    docker run -e EXTERNAL_IP=<EXTERNAL_IP> -e PORT=<PORT> -v <RESULTS_PATH>:/output registry.sonata-nfv.eu:5000/tng-vnv-probe-netcat:latest