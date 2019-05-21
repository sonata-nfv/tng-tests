# Mqtt stress Probe

This probe executes a mqtt stress test against an IP:port. It generates a results.log file in /output that can be accessed via docker volume


| Parameter | Mandatory |
|---|---|
|EXTERNAL_IP| Yes|

## Docker execution example
	 docker run -it --entrypoint /bin/bash probes/stress (debug)
	 docker container run -d --rm --name probes-stress    (dev phase)