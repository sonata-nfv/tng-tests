|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Benchmark_MQTT_Broker__ | |
| __Test Purpose__ | | Get metrics from a MQTT broker in Sonata or OSM| |
| __Configuration__ | | The TD is based on the MQTT benchmark test| |
| __Test Tool__ | | Robot Framework| |
| __Metric__ | | Response times| |
| __References__ | | https://github.com/sonata-nfv/tng-vnv-executor/ | |
| __Applicability__ | | N/A |
| __Pre-test conditions__ | | The packages that contain the NS and Tests will be created before the test execution| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Setting variables | The VnV env variables are setted|
| | 2 | Service Package On-Boarding | Service Package is on-boarded in VnV catalog|
| | 3 | Test Package On-Boarding | Test Package is on-boarded in VnV catalog|
| | 4 | Check Test Execution | VnV launches and executes the test |
| | 5 | Obtain graylogs | Get the logs|  
| __Test Verdict__ | | The results will show content from the probes | |
| __Additional resources__ | | | |
