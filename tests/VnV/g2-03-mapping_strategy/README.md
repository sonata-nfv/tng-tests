|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Mapping Strategy__ | |
| __Test Purpose__ | | To ensure that the mapping strategy of TD-NSD based on testing tags works as expected| |
| __Configuration__ | | The TD will be a simply test based on the PING one using several testing tags to cover all mapping possibilities| |
| __Test Tool__ | | Robot Framework| |
| __Metric__ | | No metric (ping test)| |
| __References__ | | https://github.com/sonata-nfv/tng-vnv-executor/ | |
| __Applicability__ | | Variations of this test case can be performed modifying the TD and NSD to cover all scenarios: <ul><li>NSD and TD don't match</li><li>NSD single testing tag matches with multiple TDs so multiple test plans will be generated</li><li>TD single testing tag matches with multiple NSDs so multiple test plans will be generated</li></ul>| |
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
