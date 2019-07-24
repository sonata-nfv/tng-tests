|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | __slice__ | |
| __Test Purpose__ | | Validate the process to instantiate & terminate 2 Network Slices Instances based on two different Networks Slice Templates with one shared NS. | |
| __Configuration__ | | The test uses a Network Slice Templated descriptor (NSTd) wich defines the Network Slice to instantiate and terminate. Each Network Slice contains 3 Network Services (NSs) interconnected among them by 5 Virtual Links. The difference between NSTds are the type of components within the NSs; one NSTd only contains CNFs (one of them shared), while the other NSTd contains 2 VNFs and 1 CNF which is shared.| |
| __Test Tool__ | | | |
| __Metric__ | | | |
| __References__ | | https://github.com/sonata-nfv/tng-slice-mngr | |
| __Applicability__ | | | |
| __Pre-test conditions__ | | | |
| __Test sequence__ | Step | Description | Result |
| | 1 | Setting Up Test Environment | Prepares the environment information to be used during the test. |
| | 2 | VNF Based Service Package On-Boarding | Service (NSs and VNFs) package is on-boarded in SP catalog. |
| | 3 | CNF Based Service Package On-Boarding | Service (NSs and CNFs) package is on-boarded in SP catalog. |
| | 4 | CNF-NS Based Network Slice Template On-Boarding | A Network Slice Template descriptor with three NSs ( all of them with CNFs and one is shared) is on-boarded in SP catalog. |
| | 5 | Hybrid Network Slice Template On-Boarding | A Network Slice Template descriptor with three NSs (two VNF based, one CNF based and shared) is on-boarded in SP catalog. |
| | 6 | First Network Slice Instantiation | An instantiation request reaches the Network Slice Manager throught the GTK and starts the intra-process requests: creates the NSIr, slice-vld creation (5), NSs instances. |
| | 7 | Validates First Instantiation Process | Validates if all the process is well-done by checking the status (INSTANTIATED) of the slice instantiation request. |
| | 8 | Second Network Slice Instantiation | An instantiation request reaches the Network Slice Manager throught the GTK and starts the intra-process requests: creates the NSIr, slice-vld creation (only those not shared), NSs instances (only those not shared). |
| | 9 | Validates Second Instantiation Process | Validates if all the process is well-done by checking the status (INSTANTIATED) of the slice instantiation request. |
| | 10 | First Network Slice Termination | A termination request reaches the Network Slice Manager throught the GTK and starts all the intra-process requests: terminate  NSs and remove slice-VLDs, only those NOT SHARED. |
| | 11 | Validate First Termination Process | Validates if all the process is well-done by checking the status (TERMINATED) of the slice termination request. |
| | 12 | Second Network Slice Termination | A termination request reaches the Network Slice Manager throught the GTK and starts all the intra-process requests: terminate NSs and remove slice-VLDs, including the SHARED resources. |
| | 13 | Validate Second Termination Process | Validates if all the process is well-done by checking the status (TERMINATED) of the slice termination request. |
| | 14 | Remove CNF-NS Based Network Slice Template | Deletes the CNF-NS based NST descriptor previously on-boarded in order to leave the environment clean for other tests. |
| | 15 | Remove Hybrid Network Slice Template | Deletes the hybrid NST descriptor previously on-boarded in order to leave the environment clean for other tests. |
| | 16 | Remove VNF Based Service Package | Deletes the VNF based service package previously on-boarded in order to leave the environment clean for other tests. |
| | 17 | Remove CNF Based Service Package | Deletes the CNF based service package previously on-boarded in order to leave the environment clean for other tests. |
| __Test Verdict__ | | If no error appeared in all actions and the NSIr finishes with its status and those of the NS instances as "Terminated".|
| __Additional resources__ | | | |
# Scenario
![Network Slice Architecture](./images/slice_shared_ns_architecture.PNG)
# Test flow
![Instantiation Testflow](./images/slice_instantiation_flow.png)