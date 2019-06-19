*** Settings ***
Documentation     Network Slice Test 3.1.1 - Create a NST (upload NSs), instantiate/terminate a NSI based on the NST and remove the NST (and NSs).
Library           tnglib
Library           DateTime

*** Variables ***
${HOST}                 http://int-sp-ath.5gtango.eu   #  the name of SP we want to use
${INSTANTIATED}         INSTANTIATED
${TERMINATED}           TERMINATED
${FILE_SOURCE_DIR}      ./packages   # to be modified and added accordingly if package is not on the same folder as test
${FILE_SERVICE_NAME}    eu.5gtango.test-ns-nsid1v.0.1.tgo    # The package to be uploaded and tested
${FILE_TEMPLATE_PATH}   NSTD/3nsid1v_nstd.yaml
${NSI_NAME}             sliceTest_311-
${NSI_DESCRIPTION}      Testing_slice_test_case_3.1.1


*** Test Cases ***
Setting the SP Path
    Set SP Path     ${HOST}
    ${result} =    Sp Health Check
    Should Be True   ${result}

Upload the Package
    ${result} =    Upload Package      ${FILE_SOURCE_DIR}/${FILE_SERVICE_NAME}
    Should Be True     ${result[0]}
    ${service} =    Map Package On Service    ${result[1]}
    Log     ${service}
    Should Be True    ${service[0]}
    Set Suite Variable    ${PACKAGE_UUID}    ${service[1]}
    Log     ${PACKAGE_UUID}

Upload the Slice Template
    ${nst_result} =    Create Slice Template     ${FILE_SOURCE_DIR}/${FILE_TEMPLATE_PATH}
    Log     ${nst_result}
    Should Be True     ${nst_result[0]}
    Set Suite Variable     ${nst_uuid}    ${nst_result[1]}
    Log     ${nst_uuid}

Deploy a Slice instance_uuid
    ${date} = 	Get Current Date
    ${nsi_result} =    Slice Instantiate     ${nst_uuid}    name=${NSI_NAME}${date}    description=${NSI_DESCRIPTION}
    Log     ${nsi_result}
    Should Be True     ${nsi_result[0]}
    Set Suite Variable     ${nsi_inst_req_uuid}    ${nsi_result[1]}
    Log     ${nsi_inst_req_uuid}

Wait For Instantiated
    Wait until Keyword Succeeds     15 min    30 sec    Check Slice Instance Request Status
    ${status} =     Get Request    ${nsi_inst_req_uuid}
    Set Suite Variable    ${slice_id}    ${status[1]['instance_uuid']}

Terminate the Slice Instance
    ${nsi_result} =    Slice Terminate     ${slice_id}
    Log    ${nsi_result}
    Should Be True    ${nsi_result[0]}
    Set Suite Variable     ${nsi_term_req_uuid}    ${nsi_result[1]}
    Log     ${nsi_term_req_uuid}

Wait For Terminated
    Wait until Keyword Succeeds     5 min    5 sec    Check Slice Terminate Request Status

Remove Slice Template
    ${nst_result} =   Delete Slice Template     ${nst_uuid}
    Log     ${nst_result}
    Should Be True     ${nst_result[0]}

Clean the Package
    ${result}=    Remove Package    package_uuid=${PACKAGE_UUID}

*** Keywords ***
Check Slice Instance Request Status
    ${REQUEST_instance_dict} =     GET REQUEST    ${nsi_inst_req_uuid}
    Should Be Equal    ${INSTANTIATED}    ${REQUEST_instance_dict[1]['status']}

Check Slice Terminate Request Status
    ${REQUEST_terminate_dict} =     GET REQUEST    ${nsi_term_req_uuid}
    Should Be Equal    ${TERMINATED}    ${REQUEST_terminate_dict[1]['status']}



