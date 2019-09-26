#!/bin/bash
set -e

# directly call the validator (to make error pasing simple)
tng-validate --project NSID1V -t
tng-validate --project NSID2V -t
tng-validate --project NSID3V -t
tng-validate --project NSID1C -t
tng-validate --project NSID2C -t
tng-validate --project NSID3C -t
tng-validate --project NSINDP1C -t
tng-validate --project NSCPE_onap -t

# package all projects
tng-pkg -p NSID1C --skip-validation
tng-pkg -p NSID1V --skip-validation
tng-pkg -p NSID1V_cirros_OSM --skip-validation
tng-pkg -p NSID1V_cirros_SONATA --skip-validation
tng-pkg -p NSID1V_cirros_SONATA_no_tags --skip-validation
tng-pkg -p NSID2C --skip-validation
tng-pkg -p NSID3C --skip-validation
tng-pkg -p NSID2V --skip-validation
tng-pkg -p NSID3V --skip-validation
tng-pkg -p NSIMPSP --skip-validation
tng-pkg -p NSIMPSP_no_tags --skip-validation
tng-pkg -p NSINDP1C --skip-validation
tng-pkg -p NSTD_VNF --skip-validation
tng-pkg -p NSTD_CNF --skip-validation
tng-pkg -p NSTD_hybrid --skip-validation
tng-pkg -p TSTGNRPRB --skip-validation
tng-pkg -p TSTIMPSP --skip-validation
tng-pkg -p NSID1V_cirros_OSM --skip-validation
tng-pkg -p TSTPING --skip-validation
tng-pkg -p TSTIMHLS --skip-validation
tng-pkg -p TSTPING_2_parallel_probes --skip-validation
tng-pkg -p NSID1V_osm_charms --skip-validation
tng-pkg -p NSSQHA --skip-validation
tng-pkg -p NSID1V_cirros_SONATA_NS_testing_tag_matches_multiple_TD_testing_tag --skip-validation
tng-pkg -p NSID1V_cirros_SONATA_TD_testing_tag_matches_multiple_NS_testing_tag_1 --skip-validation
tng-pkg -p NSID1V_cirros_SONATA_TD_testing_tag_matches_multiple_NS_testing_tag_2 --skip-validation
tng-pkg -p TSTPING_2_instances_probes --skip-validation
tng-pkg -p TSTPING_dependency_2_probes --skip-validation
tng-pkg -p TSTPING_SONATA --skip-validation
tng-pkg -p TSTPING_NS_testing_tag_matches_multiple_TD_testing_tag_1 --skip-validation
tng-pkg -p TSTPING_NS_testing_tag_matches_multiple_TD_testing_tag_2 --skip-validation
tng-pkg -p TSTPING_TD_testing_tag_matches_multiple_NS_testing_tag --skip-validation
tng-pkg -p TSTPING_testing_tag_not_match --skip-validation
tng-pkg -p TSTIMPSP_parser_multiple_cases --skip-validation
tng-pkg -p NSID1V_AND_TSTPING_cirros_SONATA --skip-validation
tng-pkg -p TSTTELNET_osm_cloud_init --skip-validation
tng-pkg -p NSID1V_ubuntu_OSM_cloud_init --skip-validation
tng-pkg -p HEADLESS_BROWSER --skip-validation
tng-pkg -p NSCPE_onap --skip-validation
tng-pkg -p NSMQTT_OSM --skip-validation
tng-pkg -p TSTINDP --skip-validation
tng-pkg -p TSTMQTT --skip-validation



