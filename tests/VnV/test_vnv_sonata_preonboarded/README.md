|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Deploy_OSM_Chamrs__ | |
| __Test Purpose__ | | Executing a test with a service wich is already onboarded in the VnV| |
| __Configuration__ | | The TD will be based on the PING test| |
| __Test Tool__ | | Robot Framework| |
| __Metric__ | | No metric (ping test)| |
| __References__ | | https://github.com/sonata-nfv/tng-vnv-executor/ | |
| __Applicability__ | | N/A |
| __Pre-test conditions__ | | The packages that contain the NS and Tests will be created before the test execution| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Setting variables | The VnV env variables are setted|
| | 2 | Test Package On-Boarding | Test Package is on-boarded in VnV catalog|
| | 3 | Check Test Execution | VnV launches and executes the test |
| | 4 | Obtain graylogs | Get the logs|  
| __Test Verdict__ | | The results will show content from the probes | |
| __Additional resources__ | | | |
