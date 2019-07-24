# Traceability Matrix

The next table shows the relationship between the VnV tests and the used Test Package and Service Package:

| Test | Test Case | Service Package | Test Package|
| --- | --- | --- | --- |
|g1-01-deploy_service_and_test_sonata| test_vnv_hello_world-connectivity_sonata_vnf | NSID1V | TSTPING |
|g1-02-deploy_service_and_test_osm| test_vnv_hello_worldconnectivity_sonata_vnf-connectivity_osm_vnf | NSID1V_cirros_OSM | TSTPING |
|g1-03-deploy_service_and_test_onap||  | TSTPING |
|g1-04-deploy_pre_onboarded_service_sonata| test_vnv_sonata_preonboarded | NSID1V| TSTPING|
|g1-05-deploy_pre_onboarded_service_osm| test_vnv_osm_preonboarded | NSID1V_cirros_OSM | TSTPING |
|g1-06-deploy_service_cloud_init_osm| test_vnv_osm_cloud_init | NS1D1V_cirros_OSM_cloud_init | TSTPING |
|g1-07-deploy_service_charms_osm| test_vnv_osm_chams | NSID1V_osm_charms | TSTPING |
|g1-08-grab_metrics_from_sonata||||
|g1-09-storage_metrics_from_sonata||| |
|g1-09-test_hybrid_package| test_hybrid_package | NSID1V_hybrid | TSTPING |
|g2-01-multiple_parallel_probes| Modifying instances field |NSID1V_cirros_SONATA_no_tags |TSTPING_2_instances_probes||
|g2-01-multiple_parallel_probes| Using two probes |NSID1V_cirros_SONATA_no_tags |TSTPING_2_parallel_probes||
|g2-02-one_probe_start_after_another|Two probes where one has a dependency to the first one|NSID1V_cirros_SONATA_no_tags|TSTPING_dependency_2_probes||
|g2-03-mapping_strategy| NS and TD testing tags don't match |NSID1V_cirros_SONATA_no_tags |TSTPING_testing_tag_not_match ||
|g2-03-mapping_strategy| Single NS testing tag matches with multiple TDs testing tags|NSID1V_cirros_SONATA_NS_testing_tag_matches_multiple_TD_testing_tag|TSTIMPSP_NS_testing_tag_matches_multiple_TD_testing_tag, TSTPING_NS_testing_tag_matches_multiple_TD_testing_tag|
|g2-03-mapping_strategy| Single TD testing tag matches with multiple NSs testing tags|NSID1V_cirros_SONATA_TD_testing_tag_matches_multiple_NS_testing_tag_1, NSIMPSP_TD_testing_tag_matches_multiple_NS_testing_tag_2|TSTPING_TD_testing_tag_matches_multiple_NS_testing_tag|
|g2-04-retrigger_a_test_manually| |NSID1V_cirros_SONATA_no_tags |TSTPING_2_instances_probes, TSTPING_2_parallel_probes, TSTPING_dependency_2_probes|
|g2-05-parser_multiple_cases| |NSID1V_cirros_SONATA_no_tags (Ping), NSIMPSP_no_tags (IMPSP) |TSTPING_parser_multiple_cases, TSTIMPSP_parser_multiple_cases||
|test_analytic_engine| | NSIMPSP| TSTIMPSP |
|test_immersive-media-pilot_e2e-HLS| | NSIMPSP | TSTIMHLS |
|test_immservive-media-pilot_e2e-streaming-performance | | NSIMPSP | TSTIMPSP |
|test_vnv_hello_world | connectivity_osm_vnf | NSID1V_cirros_OSM | TSTPING |
|test_vnv_hello_world | connectivity_sonata_vnf | NSID1V | TSTPING |
|test_vnv_hello_world | performance_osm_vnf | ?? | ?? |
|test_vnv_hello_world | performance_sonata_cnf | NSINDP1C | TSTINDP |
|test_vnv_hello_world | performance_sonata_vnf | NSIMPSP | TSTIMPSP |
|vnv-onboarding-phase| | - | - |
