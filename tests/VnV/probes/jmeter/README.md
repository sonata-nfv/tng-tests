# Mqtt stress Probe

This probe executes a mqtt stress test against an IP:port. It generates a results.log file in /output that can be accessed via docker volume


| Parameter | Mandatory |
|---|---|
|EXTERNAL_IP| Yes|

## Docker execution example
	 docker build -t probes/stress .
	 docker container run -e "IP=192.168.1.184" -e "PORT=1883" --rm --name probes-stress  probes/stress  (dev)
	 
	 docker run -it --entrypoint /bin/bash probes/stress (optional)