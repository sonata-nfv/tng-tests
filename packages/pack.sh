#!/bin/bash
set -e
# directly call the validator (to make error pasing simple)
tng-validate --project NSID1V -t
tng-validate --project NSID2V -t
tng-validate --project NSID1C -t
tng-validate --project NSID2C -t
tng-validate --project NSINDP1C -t

# package all projects
tng-pkg -p NSID1C --skip-validation
tng-pkg -p NSID1V --skip-validation
tng-pkg -p NSID1V_cirros_OSM --skip-validation
tng-pkg -p NSID1V_cirros_SONATA --skip-validation
tng-pkg -p NSID2C --skip-validation
tng-pkg -p NSID2V --skip-validation
tng-pkg -p NSIMPSP --skip-validation
tng-pkg -p NSINDP1C --skip-validation
tng-pkg -p NSTD --skip-validation
tng-pkg -p TSTGNRPRB --skip-validation
tng-pkg -p TSTIMPSP --skip-validation
tng-pkg -p TSTINDP --skip-validation
tng-pkg -p TSTPING --skip-validation
tng-pkg -p TSTPING_SONATA --skip-validation
