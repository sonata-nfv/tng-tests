|||||
| :--- | :--- | :--- | :--- |
| __Test Case Name__ | | test_service_migration_k8s | |
| __Test Purpose__ | | Test the migration of a CNF| |
| __Configuration__ | | A NS composed by one CNF is deployed with the Service Platform| |
| __Test Tool__ | | Robot Framework, using Tnglib | |
| __Metric__ | | Boolean (success or not) | |
| __References__ | |  | |
| __Applicability__ | | Variations of this test case can be performed to test it for different CNFs and multi-CNF services  | |
| __Pre-test conditions__ | | A running Service Platform| |
| __Test sequence__ | Step | Description | Result |
| | 1 | Service Package On-Boarding | Service Package is on-boarded in the SP|
| | 2 | Deploy Network Service | Network Service is deployed in the SP |
| | 3 | Check Network Service instantiation correctness | Confirm that the NS was deployed without errors |
| | 5 | Migrate the CNF | The CNF is migrated from one k8s cluster to the other |
| | 6 | Check CNF migration correctness | Confirm that the migration was executed without errors |
| | 8 | Terminate Network Service | Delete the NS deployed |
| __Test Verdict__ | | Network Service's CNF was migrated succesfully | |
| __Additional resources__ | | | |

