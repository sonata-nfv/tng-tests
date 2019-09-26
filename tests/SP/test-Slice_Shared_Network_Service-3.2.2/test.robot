*** Settings ***
Documentation     Network Slice Test 3.2.2 - Creates a NST (upload NSs), instantiates/terminate two NSIs sharing one NSs.
Library           tnglib
Library           DateTime

*** Variables ***
#${HOST}                        http://int-sp-ath.5gtango.eu   #  the name of SP we want to use
${FILE_SOURCE_DIR}             ./packages   # to be modified and added accordingly if package is not on the same folder as test
${FILE_SERVICE_NAME_VNF}       eu.5gtango.test-ns-nsid1v.0.1.tgo    # The package to be uploaded and tested
${NS_PACKAGE_SHORT_NAME_VNF}   test-ns-nsid1v
${FILE_SERVICE_NAME_CNF}       eu.5gtango.test-ns-nsid1c.0.1.tgo    # The package to be uploaded and tested
${NS_PACKAGE_SHORT_NAME_CNF}   test-ns-nsid1c
${FILE_TEMPLATE_CNF}           NSTD_CNF/3nsidc_nstd.yml
${FILE_TEMPLATE_HYBRID}        NSTD_hybrid/hybrid_nstd.yml
${NSI_1_NAME}                  sliceTest_322_cnf
${NSI_2_NAME}                  sliceTest_322_hybrid
${NSI_DESCRIPTION}             Testing_slice_test_case_3.2.2
${INSTANTIATED}                INSTANTIATED
${TERMINATED}                  TERMINATED

*** Test Cases ***
Setting Up Test Environment
    Set SP Path     ${HOST}
    ${result}=    Sp Health Check
    Should Be True   ${result}

VNF Based Service Package On-Boarding
    # Uploading NS composed with VNF
    ${result_vnf}=    Upload Package      ${FILE_SOURCE_DIR}/${FILE_SERVICE_NAME_VNF}
    Should Be True     ${result_vnf[0]}
    ${service_vnf}=    Map Package On Service    ${result_vnf[1]}
    Log     ${service_vnf}
    Should Be True    ${service_vnf[0]}
    Set Suite Variable    ${PACKAGE_VNF_UUID}    ${service_vnf[1]}
    Log     ${PACKAGE_VNF_UUID}

CNF Based Service Package On-Boarding
    # Uploading NS composed with CNF    
    ${result_cnf}=    Upload Package      ${FILE_SOURCE_DIR}/${FILE_SERVICE_NAME_VNF}
    Should Be True     ${result_cnf[0]}
    ${service_cnf}=    Map Package On Service    ${result_cnf[1]}
    Log     ${service_cnf}
    Should Be True    ${service_cnf[0]}
    Set Suite Variable    ${PACKAGE_CNF_UUID}    ${service_cnf[1]}
    Log     ${PACKAGE_CNF_UUID}

CNF-NS Based Network Slice Template On-Boarding
    # Upload the NST with CNF (one is shared)
    ${nst_result_cnf}=    Create Slice Template     ${FILE_SOURCE_DIR}/${FILE_TEMPLATE_CNF}
    Log     ${nst_result_cnf}
    Should Be True     ${nst_result_cnf[0]}
    Set Suite Variable     ${nst_cnf_uuid}    ${nst_result_cnf[1]}
    Log     ${nst_cnf_uuid}

Hybrid Network Slice Template On-Boarding
    # Upload the NST with VNF and shared CNF
    ${nst_hybrid_result}=    Create Slice Template     ${FILE_SOURCE_DIR}/${FILE_TEMPLATE_HYBRID}
    Log     ${nst_hybrid_result}
    Should Be True     ${nst_hybrid_result[0]}
    Set Suite Variable     ${nst_hybrid_uuid}    ${nst_hybrid_result[1]}
    Log     ${nst_hybrid_uuid}

First Network Slice Instantiation
    ${date}= 	Get Current Date
    ${nsi_1_result}=    Slice Instantiate     ${nst_cnf_uuid}    name=${NSI_1_NAME}${date}    description=${NSI_DESCRIPTION}
    Log     ${nsi_1_result}
    Should Be True     ${nsi_1_result[0]}
    Set Suite Variable     ${nsi_inst_req_uuid}    ${nsi_1_result[1]}
    Log     ${nsi_inst_req_uuid}

Validates First Instantiation Process
    Wait until Keyword Succeeds     15 min    30 sec    Check Instance Status
    ${request_1}=     Get Request    ${nsi_inst_req_uuid}
    Set Suite Variable    ${slice_1_id}    ${request_1[1]['instance_uuid']}

Second Network Slice Instantiation
    ${date}= 	Get Current Date
    ${nsi_2_result}=    Slice Instantiate     ${nst_hybrid_uuid}    name=${NSI_2_NAME}${date}    description=${NSI_DESCRIPTION}
    Log     ${nsi_2_result}
    Should Be True     ${nsi_2_result[0]}
    Set Suite Variable     ${nsi_inst_req_uuid}    ${nsi_2_result[1]}
    Log     ${nsi_inst_req_uuid}

Validates Second Instantiation Process
    Wait until Keyword Succeeds     15 min    30 sec    Check Instance Status
    ${request_2}=     Get Request    ${nsi_inst_req_uuid}
    Set Suite Variable    ${slice_2_id}    ${request_2[1]['instance_uuid']}

First Network Slice Termination
    ${nsi_result}=    Slice Terminate     ${slice_1_id}
    Log    ${nsi_result}
    Should Be True    ${nsi_result[0]}
    Set Suite Variable     ${nsi_term_req_uuid}    ${nsi_result[1]}
    Log     ${nsi_term_req_uuid}

Validate First Termination Process
    Wait until Keyword Succeeds     5 min    5 sec    Check Terminate Status

Second Network Slice Termination
    ${nsi_result}=    Slice Terminate     ${slice_2_id}
    Log    ${nsi_result}
    Should Be True    ${nsi_result[0]}
    Set Suite Variable     ${nsi_term_req_uuid}    ${nsi_result[1]}
    Log     ${nsi_term_req_uuid}

Validate Second Termination Process
    Wait until Keyword Succeeds     5 min    5 sec    Check Terminate Status

Remove CNF-NS Based Network Slice Template
    ${nst_cnf_result}=   Delete Slice Template     ${nst_cnf_uuid}
    Log     ${nst_cnf_result}
    Should Be True     ${nst_cnf_result[0]}

Remove Hybrid Network Slice Template
    ${nst_hybrid_result}=   Delete Slice Template     ${nst_hybrid_uuid}
    Log     ${nst_hybrid_result}
    Should Be True     ${nst_hybrid_result[0]}

Remove VNF Based Service Package
    ${result_vnf}=    Remove Package    package_uuid=${PACKAGE_VNF_UUID}
    Log    ${result_vnf}
Remove CNF Based Service Package
    ${result_cnf}=    Remove Package    package_uuid=${PACKAGE_CNF_UUID}
    Log    ${result_cnf}
*** Keywords ***
Check Instance Status
    ${REQUEST_instance_dict}=     Get Request    ${nsi_inst_req_uuid}
    Should Be Equal    ${INSTANTIATED}    ${REQUEST_instance_dict[1]['status']}

Check Terminate Status
    ${REQUEST_terminate_dict}=     Get Request    ${nsi_term_req_uuid}
    Should Be Equal    ${TERMINATED}    ${REQUEST_terminate_dict[1]['status']}