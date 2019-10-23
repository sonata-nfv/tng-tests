|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Parser Multiple Cases__ | |
| __Test Purpose__ | | To ensure that parser can extract the verdicts of the test result in multiple cases| |
| __Configuration__ | | The TD will use two probes: one that generates a json result file and other that generates a txt result file. This TD will contain several validations from both probes and files types: <ul><li>TXT that contains "String"</li><li>TXT that not contains "String"</li><li>JSON field validation</li><li>JSON field2 validation2</li></ul>| |
| __Test Tool__ | | Robot Framework| |
| __Metric__ | | No metric| |
| __References__ | | https://github.com/sonata-nfv/tng-vnv-executor/ | |
| __Applicability__ | | | |
| __Pre-test conditions__ | | The packages that contain the NS and Tests will be created before the test execution| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Service Package On-Boarding | Service Package is on-boarded in VnV catalog|
| | 2 | Test Package On-Boarding | Test Package is on-boarded in VnV catalog|
| | 3 | Check Service Instantiation | Service instance is up and running |
| | 4 | Check Test Execution | VnV launches and executes the test |
| | 5 | Check Test Completion | VnV test execution is completed |
| | 6 | Check No Running Instances In SP | After test, the instantiated service must be deleted from Service Platform|  
| | 7 | Check Stored Results | The test results are stored in the test results repository |
| __Test Verdict__ | | The results will show content from all probes | |
| __Additional resources__ | | | |
