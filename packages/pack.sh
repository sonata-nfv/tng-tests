#!/bin/bash
set -e
# directly call the validator (to make error pasing simple)
tng-validate --project NSID1V -t
tng-validate --project NSID2V -t
tng-validate --project NSID1C -t
tng-validate --project NSID2C -t

# package all projects
tng-pkg -p NSID1V --skip-validation
tng-pkg -p NSID2V --skip-validation
tng-pkg -p NSID1C --skip-validation
tng-pkg -p NSID2C --skip-validation
