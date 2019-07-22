|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Monitoring metrics__ | |
| __Test Purpose__ | | Check that monitoring metrics from a new deployed NS are availble in the VnV monitoring framework | |
| __Configuration__ | |A NS composed by more than one VNFs is deployed on the service platform. | |
| __Test Tool__ | | Robot Framework, using Tnglib| |
| __Metric__ | | Boolean (success or not), execution time | |
| __References__ | | | |
| __Applicability__ | | This test case can be performed to test if monitoring framework is setup correcty collecting custom and default metrics | |
| __Pre-test conditions__ | | The packages that contain the NS and Tests will be created before the test execution| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Service Package On-Boarding |Service Package is on-boarded in VnV catalog |
| | 2 | Test Package On-Boarding | Test Package is on-boarded in VnV catalog | 
| | 3 | Check Service Instantiation | Immersive Media Service instance is up and running | 
| | 4 | Check Test Execution | VnV launches executes the test |
| | 5 | Check Test Completion | VnV test execution is completed |
| | 6 | Check monitoring metrics | Retrieve monitoring data for specific NS and VNF |
| | 7 | Check No Running Instances In SP | Check No Running Instances In SP	After test, the instantiated service must be deleted from Service Platform |
| __Test Verdict__ | | Monitoring data collected, stored and retrieved correctly | |
| __Additional resources__ | | | |