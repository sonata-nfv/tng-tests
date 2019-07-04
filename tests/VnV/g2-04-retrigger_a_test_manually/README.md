|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Retrigger a test manually__ | |
| __Test Purpose__ | | To ensure that a test can be relaunched manually| |
| __Configuration__ | | Not required| |
| __Test Tool__ | | Robot Framework| |
| __Metric__ | | No metric| |
| __References__ | | https://github.com/sonata-nfv/tng-vnv-executor/ | |
| __Applicability__ | | | |
| __Pre-test conditions__ | | The test plan to relaunch will be present in the VnV platform| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Get one test plan with ERROR/COMPLETED status from the list of executed test plans|
| | 2 | Using the REST API, change the status to SCHEDULED|
| | 3 | Check Service Instantiation | Service instance is up and running |
| | 4 | Check Test Execution | VnV launches and executes the test |
| | 5 | Check Test Completion | VnV test execution is completed |
| | 6 | Check Stored Results | The test results are stored in the test results repository |
| | 7 | Check No Running Instances In SP | After test, the instantiated service must be deleted from Service Platform|  
| __Test Verdict__ | | The results will show content from probes | |
| __Additional resources__ | | | |
