|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __VNFSCALE__ | |
| __Test Purpose__ | | Manual scale-out and scale-in of a Network Service's VNF| |
| __Configuration__ | | A NS composed by one VNF is deployed on the Service Platform| |
| __Test Tool__ | | Robot Framework, using Tnglib | |
| __Metric__ | | Boolean (success or not), execution time | |
| __References__ | |  | |
| __Applicability__ | | Variations of this test case can be performed to test multiple scales  | |
| __Pre-test conditions__ | | The Network Service that contain the VNF will be created before the test execution| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Service Package On-Boarding | Service Package is on-boarded in the SP|
| | 2 | Deploy Network Service | Network Service is deployed in the SP |
| | 3 | Check Network Service instantiation | Confirm that the NS was deployed without errors |
| | 4 | VNF Scale-out | Create the new VNF |
| | 5 | Check VNF scalation | Confirm that the VNF was scaled out without errors |
| | 4 | VNF Scale-in | Terminate the scaled VNF |
| | 5 | Check VNF scalation | Confirm that the VNF was scaled in without errors |
| | 7 | Terminate Network Service | Delete the NS deployed |
| | 8 | Clean the SP | Remove any packages from the SP | 
| __Test Verdict__ | | Network Service's VNF was scaled succesfully | |
| __Additional resources__ | | | |

