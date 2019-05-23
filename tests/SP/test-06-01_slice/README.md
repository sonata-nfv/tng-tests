|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __slice__ | |
| __Test Purpose__ | | Validate the process to instantiate & terminate a Network Slice composed by multiple Network Services.| |
| __Configuration__ | | A Network Slice contains 3 Network Services interconnected among them by 2 Virtual Links (networks). The test uses a Network Slice Templated descriptor (NSTd) wichi defines the Network Slice to instantiate and terminate.| |
| __Test Tool__ | | | |
| __Metric__ | | | |
| __References__ | | https://github.com/sonata-nfv/tng-slice-mngr | |
| __Applicability__ | | | |
| __Pre-test conditions__ | | The NSTd.yaml file and the packages that contain the NSs, VNFs will be uploadedto the SP before the test execution.| |
| __Test sequence__ | Step | Description | Result |
| | 1 | NSs and VNFs Packages On-Boarding | NSs and VNFs packages are on-boarded in SP catalog.|
| | 2 | NSTd On-Boarding | Network Slice Template descriptor is on-boarded in SP catalog.|
| | 3 | Requests Network Slice Instantiation | A request from the portal reaches the Network Slice Manager throught the GTK and creates the NSI record (NSIr). |
| | 4 | Slice VLD (VIM networks) Creation | Networks defined in the NSTd are created by the IA in the right VIM. |
| | 5 | Slice subnets (NS instances) Creation | Instantiation of the NSs composing the slice are completed in the right VIM. |
| | 6 | Check Instantiation Stored Results | Check if the NSIr & NS instances status are all "Instantiated" and the networks created. |
| | 7 | Slice subnets (NS instances) Removal | Termination of the NSs composing the slice is done, meaning the removal of the VMs created in the VIM. |
| | 8 | Slice VLD (VIM networks) Removal | All previously created networks must be deleted from the VIM. |
| | 9 | Check Termination Stored Results | Check if the NSIr & NS instances status are all "Terminated" and the networks deleted. |
| __Test Verdict__ | | If no error appeared in all actions and the NSIr finishes with its status and those of the NS instances as "Terminated".|
| __Additional resources__ | | | |
# Scenario
![Network Slice Architecture](./images/test_06_01.PNG)
# Test flow
![Instantiation Testflow](./images/slice_instantiation.png)