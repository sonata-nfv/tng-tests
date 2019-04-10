|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Immersive Media Pilot Streaming Performance__ | |
| __Test Purpose__ | | Measure the latency between the different NS components and the total latency between the video generation and the end-user player| |
| __Configuration__ | | A NS composed by three VNFs (CMS, MA, MSE) is deployed on the Service Platform. The defined test plan contains a Test Descriptor (TD) with the configuration of docker images, environment variables, dependencies, etc that will be used in the test.| |
| __Test Tool__ | | (get this info from probes)| |
| __Metric__ | | (get this info from probes)| |
| __References__ | | https://github.com/sonata-nfv/tng-vnv-executor/ | |
| __Applicability__ | | Variations of this test case can be performed modifying the TD: <ul><li>Use different image probes</li><li>Apply different validation and verification conditions</li></ul>| |
| __Pre-test conditions__ | | The packages that contain the NS and Tests will be created before the test execution| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Service Package On-Boarding | Service Package is on-boarded in VnV catalog|
| | 2 | Test Package On-Boarding | Test Package is on-boarded in VnV catalog|
| | 3 | Check Service Instantiation | Immersive Media Service instance is up and running |
| | 4 | Check Test Execution | VnV launches executes the test |
| | 5 | Check Test Completion | VnV test execution is completed |
| | 6 | Check Stored Results | The test results are stored in the test results repository |
| | 7 | Check No Running Instances In SP | After test, the instantiated service must be deleted from Service Platform|  
| __Test Verdict__ | | The ... (get benchmark condition from TD) ...| |
| __Additional resources__ | | | |

# Scenario

![mediatest](./images/mediatest.png)

# Test flow

![testflow](./images/testFlow.png)

