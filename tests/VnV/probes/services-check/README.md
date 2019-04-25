# Telnet Probe

This probe executes sshpass commands against an IP checking the services availability. It generates a results.log file in /output that can be accessed via docker volume


| Parameter | Mandatory |
|---|---|
|EXTERNAL_IP| Yes|
|USER|Yes|
|PASS|Yes|
|SERVICES|Yes|

## Docker execution example

    docker run -e EXTERNAL_IP=<EXTERNAL_IP> -e SERVICES="<SERVICE_1> <SERVICE_2> <SERVICE_n>" -e USER=<USER> -e PASS="PASS" -v <RESULTS_PATH>:/output registry.sonata-nfv.eu:5000/tng-vnv-probe-services-check:latest