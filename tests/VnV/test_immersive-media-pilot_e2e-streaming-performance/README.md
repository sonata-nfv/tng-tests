|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Immersive Media Pilot Streaming Performance__  <td colspan=2>| |
| __Test Purpose__ | | Measure the latency between the different NS components and the total latency between the video generation and the end-user player| |
| __Configuration__ | | A NS composed by three VNFs () is deployed on the Service Platform. The defined test plan contains a Test Descriptor (TD) with the configuration of docker images, environment variables, dependencies, etc that will be used in the test.| |
| __Test Tool__ | | (get this info from probes)| |
| __Metric__ | | (get this info from probes)| |
| __References__ | | https://github.com/sonata-nfv/tng-vnv-executor/ | |
| __Applicability__ | | Variations of this test case can be performed modifying the TD: <ul><li>Use different image probes</li><li>Apply different validation and verification conditions</li></ul>| |
| __Pre-test conditions__ | | The packages that contain the NS and Tests will be created before the test execution| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Service Package Onboarding | |
| | 2 | Test Package Onboarding | |
| | 3 | Check Service Instantiation | |
| | 4 | Check Test Execution | |
| | 5 | Check Test Completion | |
| | 6 | Check Stored Results | |
| | 7 | Check No Instances Running In SP | |  
| __Test Verdict__ | | | |
| __Additional resources__ | | | |