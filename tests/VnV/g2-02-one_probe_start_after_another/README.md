|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __A probe can start after another__ | |
| __Test Purpose__ | | To ensure that one probe can start after another| |
| __Configuration__ | | The TD will be based on the PING test but using two probes sections: one with no dependencies and the other depending on the first one| |
| __Test Tool__ | | Robot Framework| |
| __Metric__ | | No metric (ping test)| |
| __References__ | | https://github.com/sonata-nfv/tng-vnv-executor/ | |
| __Applicability__ | | | |
| __Pre-test conditions__ | | The packages that contain the NS and Tests will be created before the test execution| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Service Package On-Boarding | Service Package is on-boarded in VnV catalog|
| | 2 | Test Package On-Boarding | Test Package is on-boarded in VnV catalog|
| | 3 | Check Service Instantiation | Service instance is up and running |
| | 4 | Check Test Execution | VnV launches and executes the test |
| | 5 | Check Test Completion | VnV test execution is completed |
| | 6 | Check Stored Results | The test results are stored in the test results repository |
| | 7 | Check No Running Instances In SP | After test, the instantiated service must be deleted from Service Platform|  
| __Test Verdict__ | | The results will show content from the probes | |
| __Additional resources__ | | | |
