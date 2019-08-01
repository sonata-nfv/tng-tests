|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __Test Service Lifecycle in OS with elasticity policies__ | |
| __Test Purpose__ | | Check the lifecycle of a Network Service with an elasticity policy activated. Check collaboration between MANO, monitoring engine and policy engine components. Test Service Lifecycle in Openstack with elasticity policies| |
| __Configuration__ | | A NS composed by one haproxy and one squid VNF are deployed on the Service Platform. ns-squid-haproxy NS is deployed on the Service Platform upon openstack| |
| __Test Tool__ | | Robot Framework, using Tnglib | |
| __Metric__ | | Boolean (success or not), execution time | |
| __References__ | |  | |
| __Applicability__ | | Variations of this test case can be performed to test multiple policy actions  | |
| __Pre-test conditions__ | | The packages that contain the NS are created before the test execution. The policy descriptor is also defined before the test execution.| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Service Package On-Boarding | Service Package is on-boarded in the SP|
| | 2 | Runtime Policy Creation | Runtime Policy is created in the SP |
| | 3 | Define Runtime Policy as default | Attach the Runtime Policy with the deployed Service Package |
| | 4 | Deploy Network Service | Network Service is deployed in the SP |
| | 5 | Check Network Service instantiation | Confirm that the NS was deployed without errors |
| | 6 | Check Monitoring Rules | Confirm that the NS monitoring rules are enabled without errors from the monitoring engine |
| | 7 | Satisfy Monitoring Rule | generate a custom metric value that satisfies the monitoring rule |
| | 8 | Demand Elasticity policy action | policy manager requests VNF scaling out from MANO |
| | 9 | Evaluate the outcome of MANO scaling action enforcement | Confirm that the requested action is succesfully completed |
| | 10 | Deactivate Runtime Policy | Deactivate runtime policy while the NS is still deployed |
| | 9 | Terminate Network Service | Delete the NS deployed |
| | 10 | Delete Runtime Policy | Delete Runtime Policy |
| | 11 | Remove NS package | Remove NS package | 
| __Test Verdict__ | | Network service is succesfully deployed and undeployed at an OS VIM environment.Runtime Policies are enforced and deactivated succesfully | |
| __Additional resources__ | | | |

 
