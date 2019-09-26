|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Test Communication Pilot Service Lifecycle in OS with elasticity policies__ | |
| __Test Purpose__ | | Check the lifecycle of the Communication Pilot Network Service with an elasticity policy activated. Check collaboration between MANO, monitoring engine and policy engine components. Test Service Lifecycle in Openstack with elasticity policies| |
| __Configuration__ | | The Communication Pilot NS  is composed by the following vnfs: ds-vnf,rp-vnf,bs-vnf,wac-vnf and ms-vnf. They are deployed on the Sonata Service Platform upon openstack| |
| __Test Tool__ | | Robot Framework, using Tnglib | |
| __Metric__ | | Boolean (success or not), execution time | |
| __References__ | |  | |
| __Applicability__ | | Variations of this test case can be performed to test multiple policy actions  | |
| __Pre-test conditions__ | | The packages that contain the NS are created before the test execution. The policy descriptor is also defined before the test execution. The NS is already instantiated at the SP| |
| __Test sequence__ | Step | Description | Result |
| | 2 | Runtime Policy Creation | Runtime Policy is created in the SP |
| | 4 | Activate Runtime Policy for existing communication pilot NS instance | Network Service is already deployed in the SP |
| | 6 | Check Monitoring Rules | Confirm that the NS monitoring rules are enabled without errors from the monitoring engine |
| | 7 | Satisfy Monitoring Rule | generate a custom metric value that satisfies the monitoring rule |
| | 8 | Demand Elasticity policy action | policy manager requests VNF scaling out from MANO |
| | 9 | Evaluate the outcome of MANO scaling action enforcement | Confirm that the requested action is succesfully completed |
| | 10 | Deactivate Runtime Policy | Deactivate runtime policy while the NS is still deployed |
| | 10 | Delete Runtime Policy | Delete Runtime Policy |
| __Test Verdict__ | | Network service is succesfully deployed and undeployed at an OS VIM environment.Runtime Policies are enforced and deactivated succesfully | |
| __Additional resources__ | | | |




 
