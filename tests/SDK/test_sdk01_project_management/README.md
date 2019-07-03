# test_sdk01_project_management

Tool: tng-sdk-project
 Short description: Create project with different sizes.
 Parameters: Number of VNFs (1-1000)
 Collected metric: time to create, memory used by tool
 Priority: high
 Complexity: low
 Responsible: Stefan (UPB)

---

### Requirements

* bash
* `/usr/bin/time`

### Usage

Important: Clean and remove the projects in the `projects` sub-directory first!

```bash
$ ./test.sh
```

### Results

Results will be in the `results` sub-directory with the current time as filename.

Each row represents one test result, where the first row (after header) represents results with 1 VNF and row *i* results with *i* VNFs.

The first column is the time in seconds, the second max. memory consumption in kb.