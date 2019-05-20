# Mqtt stress Probe

This probe executes a mqtt stress test against an IP:port. It generates a results.log file in /output that can be accessed via docker volume


| Parameter | Mandatory |
|---|---|
|EXTERNAL_IP| Yes|

## Docker execution example
	 docker run -it --entrypoint /bin/bash probes/stress (debug)
	 docker container run -d --rm --name probes-stress --mount type=bind,src=//c/Users/asinatra/Desktop/ECLIPSE_WORKSPACE/tng-tests/tests/VnV/probes/stress/input_simulator.jmx,dst=/app/input_simulator.jmx probes/stress    (dev phase)
    docker run -e EXTERNAL_IP=<EXTERNAL_IP> -v <RESULTS_PATH>:/output registry.sonata-nfv.eu:5000/
    tng-vnv-probe-stress:latest