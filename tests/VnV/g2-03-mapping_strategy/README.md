|||||
| ---------------------- | ------ | ------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| __Test Case Name__ | | __Mapping Strategy__ | |
| __Test Purpose__ | | To ensure that the mapping strategy of TD-NSD based on testing tags works as expected| |
| __Configuration__ | | The TD will be a simple test based on the PING one using several testing tags to cover all mapping possibilities| |
| __Test Tool__ | | Robot Framework| |
| __Metric__ | | No metric (ping test)| |
| __References__ | | https://github.com/sonata-nfv/tng-vnv-executor/ | |
| __Applicability__ | | Variations of this test case can be performed modifying the TD and NSD to cover all scenarios: NSD and TD don't match. NSD single testing tag matches with multiple TDs so multiple test plans will be generated. TD single testing tag matches with multiple NSDs so multiple test plans will be generated. For the first scenario where the testing tags of the TD and NSD does no match, no test plan will be executed. For the other to scenarios a test plan will be executed for every TD and NSD where the testing tags match. | |
| __Pre-test conditions__ | | The packages that contain the NS and Tests will be created before the test execution| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Service Package On-Boarding | Service Package is on-boarded in VnV catalogue |
| | 2 | Test Package On-Boarding | Test Package is on-boarded in VnV catalogue |
| | 3 | Check Service Instantiation Test Plan 1 | Service instance is up and running |
| | 4 | Check Test Execution Test Plan 1 | VnV launches and executes the test |
| | 5 | Check Test Completion Test Plan 1 | VnV test execution is completed |
| | 6 | Check No Running Instances In SP Test Plan 1 | After the test, the instantiated service must be deleted from Service Platform| 
| | 7 | Check Service Instantiation Test Plan 2 | Service instance is up and running |
| | 8 | Check Test Execution Test Plan 2 | VnV launches and executes the test |
| | 9 | Check Test Completion Test Plan 2 | VnV test execution is completed |
| | 10 | Check No Running Instances In SP Test Plan 2 | After the test, the instantiated service must be deleted from Service Platform| 
| | 11 | Check Stored Results | The test results are stored in the test results repository | 
| __Test Verdict__ | | The results will show content from the probes | |
| __Additional resources__ | | | |
