|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Test_hybrid_package__ | |
| __Test Purpose__ | | Validate the capability of the V&V to accept packages that contains NSs and TDs| |
| __Configuration__ | | The TD will be based on the PING test| |
| __Test Tool__ | | Robot Framework| |
| __Metric__ | | No metric (ping test)| |
| __References__ | |  | |
| __Applicability__ | | N/A |
| __Pre-test conditions__ | | The packages that contain the NS and TD is be created before the test execution| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Setting variables | The VnV env variables are setted|
| | 2 | Service Package On-Boarding | Service Package is on-boarded in VnV catalog|
| | 3 | Test Package On-Boarding | Test Package is on-boarded in VnV catalog|
| | 4 | Check Test Execution | VnV launches and executes the test |
| | 5 | Obtain graylogs | Get the logs|  
| __Test Verdict__ | | The results will show content from the probes | |
| __Additional resources__ | | | |
