*** Settings ***
Documentation     Network Slice Test 3.2.1 - Creates a NST (upload NSs), instantiates/terminate two NSIs sharing one NSs.
Library           tnglib
Library           DateTime

*** Variables ***
#${HOST}                     http://int-sp-ath.5gtango.eu   #  the name of SP we want to use
${FILE_SOURCE_DIR}          ./packages   # to be modified and added accordingly if package is not on the same folder as test
${FILE_SERVICE_NAME}        eu.5gtango.test-slice-vnfs.0.1.tgo    # The package to be uploaded and tested
${FILE_TEMPLATE_PATH}       NSTD_VNF/3nsid1v_nstd.yml
${NS_PACKAGE_SHORT_NAME}    test-nsid1v
${NSI_1_NAME}               sliceTest_321_1
${NSI_2_NAME}               sliceTest_321_2
${NSI_DESCRIPTION}          Testing_slice_test_case_3.2.1
${INSTANTIATED}             INSTANTIATED
${TERMINATED}               TERMINATED


*** Test Cases ***
Setting Up Test Environment
    Set SP Path     ${HOST}
    ${result}=    Sp Health Check
    Should Be True   ${result}

Remove Previously Used Packages
    @{PACKAGES} =   Get Packages
    FOR     ${PACKAGE}  IN  @{PACKAGES[1]}
        Run Keyword If     '${PACKAGE['name']}'== '${NS_PACKAGE_SHORT_NAME}'    Remove Package      ${PACKAGE['package_uuid']}
    END 

Service Package On-Boarding
    ${result}=    Upload Package      ${FILE_SOURCE_DIR}/${FILE_SERVICE_NAME}
    Should Be True     ${result[0]}
    ${service}=    Map Package On Service    ${result[1]}
    Log     ${service}
    Should Be True    ${service[0]}
    Set Suite Variable    ${PACKAGE_UUID}    ${service[1]}
    Log     ${PACKAGE_UUID}

Network Slice Template On-Boarding
    ${nst_result}=    Create Slice Template     ${FILE_SOURCE_DIR}/${FILE_TEMPLATE_PATH}
    Log     ${nst_result}
    Should Be True     ${nst_result[0]}
    Set Suite Variable     ${nst_uuid}    ${nst_result[1]}
    Log     ${nst_uuid}

First Network Slice Instantiation
    ${date}= 	Get Current Date
    ${nsi_1_result}=    Slice Instantiate     ${nst_uuid}    name=${NSI_1_NAME}${date}    description=${NSI_DESCRIPTION}
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
    ${nsi_2_result}=    Slice Instantiate     ${nst_uuid}    name=${NSI_2_NAME}${date}    description=${NSI_DESCRIPTION}
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

Remove Network Slice Template
    ${nst_result}=   Delete Slice Template     ${nst_uuid}
    Log     ${nst_result}
    Should Be True     ${nst_result[0]}

Remove Service Package
    ${result}=    Remove Package    package_uuid=${PACKAGE_UUID}
    Log    ${result}
*** Keywords ***
Check Instance Status
    ${REQUEST_instance_dict}=     Get Request    ${nsi_inst_req_uuid}
    Should Be Equal    ${INSTANTIATED}    ${REQUEST_instance_dict[1]['status']}

Check Terminate Status
    ${REQUEST_terminate_dict}=     Get Request    ${nsi_term_req_uuid}
    Should Be Equal    ${TERMINATED}    ${REQUEST_terminate_dict[1]['status']}