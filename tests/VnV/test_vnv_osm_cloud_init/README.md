|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Deploy_OSM_Cloud-Init__ | |
| __Test Purpose__ | | Deploy a service that has cloud-init in OSM| |
| __Configuration__ | | The TD will be based on the telnet test| |
| __Test Tool__ | | Robot Framework| |
| __Metric__ | | No metric (telnet port 80)| |
| __References__ | | https://github.com/sonata-nfv/tng-vnv-executor/ | |
| __Applicability__ | | N/A |
| __Pre-test conditions__ | | The packages that contain the NS with one VNF (ubuntu) as well as cloud-init that install the nginx service and Tests with telnet probe will be created before the test execution| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Setting variables | The VnV env variables are setted|
| | 2 | Service Package On-Boarding | Service Package (ubuntu VNF with cloud-init) is on-boarded in VnV catalog|
| | 3 | Test Package On-Boarding | Test Package is on-boarded in VnV catalog|
| | 4 | Check Test Execution | VnV launches and executes the test |
| | 5 | Obtain graylogs | Get the logs|  
| __Test Verdict__ | | Exit 0 from test probe that means probe can connect to the service that was installed in the VNF | |
| __Additional resources__ | | | |
