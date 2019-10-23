|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __slice__ | |
| __Test Purpose__ | | Validate the process to instantiate & terminate a Network Slice composed by multiple Network Services.| |
| __Configuration__ | | A Network Slice contains 3 Network Services interconnected among them by 5 Virtual Links. The test uses a Network Slice Templated descriptor (NSTd) wich defines the Network Slice to instantiate and terminate.| |
| __Test Tool__ | | | |
| __Metric__ | | | |
| __References__ | | https://github.com/sonata-nfv/tng-slice-mngr | |
| __Applicability__ | | | |
| __Pre-test conditions__ | | |
| __Test sequence__ | Step | Description | Result |
| | 1 | Setting Up Test Environment & Clean Old Descriptors | Prepares the environment information to be used during the test and clean possible remainning old descriptors. |
| | 2 | Service Package On-Boarding | Service (NSs and VNFs) package is on-boarded in SP catalog. |
| | 3 | Generate the SLA Template | Creates all the necessary SLA descriptors to be used by the nest test cases. |
| | 4 | On-Boarding Network Slice Template | Network Slice Template descriptor is on-boarded in SP catalog. |
| | 5 | Deploy Network Slice Instantiation | An instantiation request reaches the Network Slice Manager throught the GTK and starts the intra-process requests: creates the NSIr, slice-vld creation, NSs instances. |
| | 6 | Validates Instantiation Process | Validates if all the process is well-done by checking the status (INSTANTIATED) of the slice instantiation request. |
| | 7 | Get All SLA Agreements | It validates if all the instantiated NSs within the Network Slice Instance got the agreement with their associated SLA. |
| | 8 | Requests Network Slice Termination | A termination request reaches the Network Slice Manager throught the GTK and starts all the intra-process requests: terminate all NSs and remove slice-VLDs. |
| | 9 | Validate Termination Process | Validates if all the process is well-done by checking the status (TERMINATED) of the slice termination request. |
| | 10 | Remove Network Slice Template | Deletes the NST descriptor previously on-boarded in order to leave the environment clean for other tests. |
| | 11 | Remove SLA Templates | Deletes the previously uploaded SLA templates used for this test. |
| | 12 | Remove Service Package | Deletes the service package previously on-boarded in order to leave the environment clean for other tests. |
| __Test Verdict__ | | If no error appeared in all actions and the NSIr finishes with its status and those of the NS instances as "Terminated".|
| __Additional resources__ | | | |
# Scenario
![Network Slice Architecture](./images/slice_3NS_architecture.PNG)
# Test flow
![Instantiation Testflow](./images/slice_instantiation_flow.png)
