|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __SLA E2E WORKFLOW__ | |
| __Test Purpose__ | | Validate the process to formulate a SLA for a NS, generate an agreement and violate it.| |
| __Configuration__ | | A SLA for a NS, containing one (1) or two (2) SLOs is formulated. The test uses the SLA and the NS in order to intantiate the latter, test the SLA formulation and violate the Agreement.| |
| __Test Tool__ | | | |
| __Metric__ | | | |
| __References__ | | https://github.com/sonata-nfv/tng-sla-mgmt | |
| __Applicability__ | | | |
| __Pre-test conditions__ | | | |
| __Test sequence__ | Step | Description | Result |
| | 1 | Upload a Service Package | NSs and VNFs packages are on-boarded in SP catalog and the NS uuid is provided.|
| | 2 | Generate a SLA for that Service (uuid) (select all supported SLOs for the service, add license info, choose a flavor ) | SLA is Formulated and on-boarded in SP catalog.|
| | 3 | Requests Network Service Instantiation | A request from the portal reaches the MANO throught the GTK, the service is instantiated and teh final agreement is automatically generated. |
| | 4 | Request the Flavor for the newlly generated SLA | The NS should be instantiated in the previously selected flavor. |
| | 5 | Licensing status check | Instantiation of the NS is checked based on the license type selected in the SLA. |
| | 6 | Violate the Agreement | A new record in SLA Manager's DB (violation's Table) must be created. |
| | 7 | Terminate the Service | The SLA status should be changed to 'TERMINATED'. |

| __Test Verdict__ | | If no error appeared in all actions the test is succesfully past.|
| __Additional resources__ | | | |
