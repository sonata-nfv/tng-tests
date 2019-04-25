# Wrk2 Probe

This probe executes the wrk2 bechmarking cli tool. It generates results.log and details.json files in /output that can be accessed via docker volume


| Parameter | Mandatory | Default value|
|---|---|---|
|EXTERNAL_IP| Yes||
|PROTOCOL|No| http||
|PORT|No| 80|
|URL_PATH|No| ""|
|CONNECTIONS|No|10|
|DURATION|No|30s|
|THREADS| No|2|
|HEADER|No|""|
|TIMEOUT|No|20S|
|RATE|No|200|
|PROXY|No|"no"|
|PROXY_IP|No|""|

## Docker execution example

    docker run -e EXTERNAL_IP=<EXTERNAL_IP> -e PORT=<PORT> -e URL_PATH=<URL_PATH> -v <RESULTS_PATH>:/output registry.sonata-nfv.eu:5000/tng-vnv-probe-wrk2:latest