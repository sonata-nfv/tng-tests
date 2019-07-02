
| Test Case Name       |   request_requests_latency_sp_kpi   | Test Case id                 |         |
|----------------------|------|----------------------------------------------------|---------|
| Test Purpose         |      | To measure the latency of each requests (requests) |         |
| Configuration        |      | SP: Staging-Paderborn. services NSID1V, NSID1C     |         |
| Test Tool            |      | Robot Framework. Prometheus.                       |         |
| Metric               |      | latency                                            |         |
| References           |      | -                                                                       |         |
| Applicability        |      | Gatekeeper, involves almost all SP components      |         |
| Pre-test conditions  |      | Clean packages. Have the number of cycles or execution time defined     |         |
| Test sequence        | 1    | Clean the packages                                 | No packages in the catalogue  |
|                      | 2    | Upload a package                                   | Package is in the catalogue  |
|                      | 3    | Instantiate the service  (Wait until finish)       | The service is instantiated  |
|                      | 4    | Terminate the service  (Wait until finish)         | The service is terminated    |
|                      | 5    | Delete the package                                 | package is deleted from the catalogue  |
|                      | 6    | Get the requests database and substract the time comsumed for instantiation and termination |   Records in a file   |
|                      | 7    | Repeat from 2 and 6                                | package upload and deleted from the catalogue  |
|                      | 8    | Generate the graphs image file from the data generated at 6   |  graph file is created  |
| Test Verdict         |      | Instantiations and termination finished correctly and package was upload and deleted in all iterations   |         |
| Additional Resources |      | Export a graph file with time consumed by each creation/deletion cycle. |         |