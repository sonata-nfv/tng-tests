<p align="center"><img src="https://github.com/sonata-nfv/tng-api-gtw/wiki/images/sonata-5gtango-logo-500px.png" /></p>

|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Testing SLA E2E__ | |
| __Test Purpose__ | | Validate the process to formulate a SLA for a NS, generate an agreement and violate it.| |
| __Configuration__ | | A SLA for a NS package is formulated which includes licensing as a SLO. The test uses the SLA and the NS in order to intantiate the latter, and test the final agreement is generated after the succesfull instantiation of the NS.| |
| __Test Tool__ | | Robot - tnglib | |
| __Metric__ | | | |
| __References__ | | https://github.com/sonata-nfv/tng-sla-mgmt | |
| __Applicability__ | | Variations of this test case can be performed modifying the TD: - Use different License type | |
| __Pre-test conditions__ | | The packages that contain the NS will be created before the test execution | |
| __Test sequence__ | Step | Description | Result |
| | 1 | Upload a Service Package | NSs and VNFs packages are on-boarded in SP catalog and the NS uuid is provided.|
| | 2 | Generate a SLA for that Service (uuid) (Choosing a License type as SLO ) | SLA is Formulated and on-boarded in SP catalog.|
| | 3 | Requests Network Service Instantiation | A request from the portal reaches the MANO throught the GTK, the service is instantiated and the final agreement is automatically generated. |
| | 4 | Licensing status check | Instantiation of the NS is checked based on the license type selected in the SLA. |
| | 5 | Terminate the Service | The SLA status should be changed to 'TERMINATED'. |
| | 5 | Clean Packages | The package that was used for the test should be deleted from the Catalogues |

| __Test Verdict__ | | If no error appeared in all actions the test is succesfully past.|
| __Additional resources__ | | | |
