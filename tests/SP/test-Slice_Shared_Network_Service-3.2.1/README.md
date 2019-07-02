|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __slice__ | |
| __Test Purpose__ | | Validate the process to instantiate & terminate 2 Network Slices Instances based on the same Networks Slice Tempalte with one shared NS. | |
| __Configuration__ | | A Network Slice contains 3 Network Services (one of them with shared=true) interconnected among them by 5 Virtual Links. The test uses a Network Slice Templated descriptor (NSTd) wich defines the Network Slice to instantiate and terminate.| |
| __Test Tool__ | | | |
| __Metric__ | | | |
| __References__ | | https://github.com/sonata-nfv/tng-slice-mngr | |
| __Applicability__ | | | |
| __Pre-test conditions__ | | | |
| __Test sequence__ | Step | Description | Result |
| | 1 | Setting Up Test Environment | Prepares the environment information to be used during the test. |
| | 2 | Service Package On-Boarding | Service (NSs and VNFs) package is on-boarded in SP catalog. |
| | 3 | On-Boarding Network Slice Template | A Network Slice Template descriptor with one shared NS is on-boarded in SP catalog. |
| | 4 | Requests First Network Slice Instantiation | An instantiation request reaches the Network Slice Manager throught the GTK and starts the intra-process requests: creates the NSIr, slice-vld creation (5), NSs instances. |
| | 5 | Validates First Instantiation Process | Validates if all the process is well-done by checking the status (INSTANTIATED) of the slice instantiation request. |
| | 6 | Requests Second Network Slice Instantiation | An instantiation request reaches the Network Slice Manager throught the GTK and starts the intra-process requests: creates the NSIr, slice-vld creation (only those not shared), NSs instances (only those not shared). |
| | 7 | Validates Second Instantiation Process | Validates if all the process is well-done by checking the status (INSTANTIATED) of the slice instantiation request. |
| | 8 | Requests Network Slice Termination | A termination request reaches the Network Slice Manager throught the GTK and starts all the intra-process requests: terminate  NSs and remove slice-VLDs, only those NOT SHARED. |
| | 9 | Validate Termination Process | Validates if all the process is well-done by checking the status (TERMINATED) of the slice termination request. |
| | 10 | Requests Network Slice Termination | A termination request reaches the Network Slice Manager throught the GTK and starts all the intra-process requests: terminate NSs and remove slice-VLDs, including the SHARED resources. |
| | 11 | Validate Termination Process | Validates if all the process is well-done by checking the status (TERMINATED) of the slice termination request. |
| | 12 | Remove Network Slice Template | Deletes the NST descriptor previously on-boarded in order to leave the environment clean for other tests. |
| | 13 | Remove Service Package | Deletes the service package previously on-boarded in order to leave the environment clean for other tests. |
| __Test Verdict__ | | If no error appeared in all actions and the NSIr finishes with its status and those of the NS instances as "Terminated".|
| __Additional resources__ | | | |
# Scenario
![Network Slice Architecture](./images/slice_shared_ns_architecture.PNG)
# Test flow
![Instantiation Testflow](./images/slice_instantiation_flow.png)
