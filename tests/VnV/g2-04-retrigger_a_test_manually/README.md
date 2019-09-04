|||||
| ---------------------- | ------ | ------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| __Test Case Name__ | | __Retrigger a test manually__ | |
| __Test Purpose__ | | To ensure that a test can be relaunched manually| |
| __Configuration__ | | Not required| |
| __Test Tool__ | | Robot Framework| |
| __Metric__ | | No metric| |
| __References__ | | https://github.com/sonata-nfv/tng-vnv-executor/ | |
| __Applicability__ | | A test plan will be executed and the status will be COMPLETED. Then the status of the test plan will be set to RETRIED and will cause then test plan to be retriggered and execute again. | |
| __Pre-test conditions__ | | The test plan to relaunch will be present in the VnV platform| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Service Package On-Boarding | Service Package is on-boarded in VnV catalogue |
| | 2 | Test Package On-Boarding | Test Package is on-boarded in VnV catalogue |
| | 3 | Check Service Instantiation | Service instance is up and running |
| | 4 | Check Test Execution | VnV launches and executes the test |
| | 5 | Check Test Completion | VnV test execution is completed |
| | 6 | Check No Running Instances In SP | After test, the instantiated service must be deleted from Service Platform|  
| | 7 | Retrigger Test Execution | Using the REST API and set the test plan to status RETRIED. A new test plan will be generated. |
| | 8 | Check Service Instantiation Retriggered Test Plan | Service instance is up and running |
| | 9 | Check Test Execution Retriggered Test Plan | VnV launches and executes the test |
| | 10 | Check Test Completion Retriggered Test Plan | VnV test execution is completed |
| | 11 | Check Stored Results | The test results are stored in the test results repository. Two test plans exists, one with status RETRIED and another one with status COMPLETED. |
| __Test Verdict__ | | The results will show content from probes | |
| __Additional resources__ | | | |