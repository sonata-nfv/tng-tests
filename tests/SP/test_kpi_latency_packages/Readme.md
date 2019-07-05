
| Test Case Name       |   request_package_latency_sp_kpi   | Test Case id                 |         |
|----------------------|------|----------------------------------------------------|---------|
| Test Purpose         |      | To measure the latency of each requests (Packages) |         |
| Configuration        |      | SP: Staging-Paderborn. Several sizes of packages small, medium, large size  |         |
| Test Tool            |      | Robot Framework. Prometheus.                       |         |
| Metric               |      | latency                                            |         |
| References           |      | -                                                                       |         |
| Applicability        |      | Gatekeeper, involves (Catalogue, Packager Validator, Rate limit, UM)    |         |
| Pre-test conditions  |      | Clean packages. Have the number of cycles or execution time defined     |         |
| Test sequence        | 1    | Clean the packages                                                      | No packages in the catalogue  |
|                      | 2    | Upload a package (Write the time comsumed in a file)                    | package is in the catalogue  |
|                      | 3    | Delete the package (Write the time consumed in a file)                  | package is deleted from the catalogue  |
|                      | 4    | Repeat 2 and 3                                                          | package upload and deleted from the catalogue  |
| Test Verdict         |      | Package was upload and deleted in all iterations                        |         |
| Additional Resources |      |  Export the time spent file. The information is in the headers X-Timing |         |