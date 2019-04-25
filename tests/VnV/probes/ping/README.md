# Ping Probe

This probe executes a ping against an IP. It generates a results.log file in /output that can be accessed via docker volume


| Parameter | Mandatory |
|---|---|
|EXTERNAL_IP| Yes|

## Docker execution example

    docker run -e EXTERNAL_IP=<EXTERNAL_IP> -v <RESULTS_PATH>:/output registry.sonata-nfv.eu:5000/tng-vnv-probe-ping:latest