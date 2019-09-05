|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Monitoring metrics__ | |
| __Test Purpose__ | | Check that monitoring metrics from a new deployed NS are available in the VnV monitoring framework | |
| __Configuration__ | |A NS composed by more than one VNFs are deployed on the service platform. | |
| __Test Tool__ | | Robot Framework, using Tnglib| |
| __Metric__ | | Boolean (success or not), execution time | |
| __References__ | | | |
| __Applicability__ | | This test case can be performed to test if monitoring framework has been set up correctly and collects custom and default metrics | |
| __Pre-test conditions__ | | The packages that contain the NS and Tests will be created before the test execution| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Service Package On-Boarding |Service Package is on-boarded in VnV catalog |
| | 2 | Test Package On-Boarding | Test Package is on-boarded in VnV catalog | 
| | 3 | Check Service Instantiation | Immersive Media Service instance is up and running | 
| | 4 | Check Test Execution | VnV launches executes the test |
| | 5 | Check monitoring metrics | Retrieve monitoring data for specific NS and VNF |
| | 6 | Check Test Completion | VnV test execution is completed |
| | 7 | Check Test Completion | VnV test execution is completed |
| | 8 | Retrieve, monitoring metrics | Check that monitoring data have been stored correctly |
| __Test Verdict__ | | Monitoring data collected, stored and retrieved correctly | |
| __Additional resources__ | | | |