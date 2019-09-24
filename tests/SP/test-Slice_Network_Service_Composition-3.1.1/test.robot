*** Settings ***
Documentation     Network Slice Test 3.1.1 - Create a NST (upload NSs), instantiate/terminate a NSI with 3 NS (VNFs) and remove the NST (and NSs).
Library           tnglib
Library           Collections
Library           DateTime

*** Variables ***
#${SP_HOST}                 http://int-sp-ath.5gtango.eu   #  the name of SP we want to use
${FILE_SOURCE_DIR}         ./packages   # to be modified and added accordingly if package is not on the same folder as test
${NS_PACKAGE_NAME}         eu.5gtango.test-slice-vnfs.0.1.tgo    # The package to be uploaded and tested
${FILE_TEMPLATE_PATH}      NSTD_VNF/3nsid1v_nstd.yml
${NS_PACKAGE_SHORT_NAME}   test-nsid1v
${NSI_NAME}                sliceTest_311-
${NSI_DESCRIPTION}         Testing_slice_test_case_3.1.1
${INSTANTIATED}            INSTANTIATED
${TERMINATED}              TERMINATED

*** Test Cases ***
Setting Up Test Environment
    Set SP Path     ${SP_HOST}
    ${result} =    Sp Health Check
    Should Be True   ${result}
Remove Previously Used Packages
    @{PACKAGES} =   Get Packages
    FOR     ${PACKAGE}  IN  @{PACKAGES[1]}
        Run Keyword If     '${PACKAGE['name']}'== '${NS_PACKAGE_SHORT_NAME}'    Remove Package      ${PACKAGE['package_uuid']}
    END 
Service Package On-Boarding
    log     ${FILE_SOURCE_DIR}
    log     ${NS_PACKAGE_NAME}
    ${result} =    Upload Package      ${FILE_SOURCE_DIR}/${NS_PACKAGE_NAME}
    Log     ${result}
    Should Be True     ${result[0]}
    ${service} =    Map Package On Service    ${result[1]}
    Log     ${service}
    Should Be True    ${service[0]}
    Set Suite Variable    ${PACKAGE_UUID}    ${service[1]}
    Log     ${PACKAGE_UUID}
Network Slice Template On-Boarding
    log     ${FILE_SOURCE_DIR}
    log     ${FILE_TEMPLATE_PATH}
    ${nst_result} =    Create Slice Template     ${FILE_SOURCE_DIR}/${FILE_TEMPLATE_PATH}
    Log     ${nst_result}
    Should Be True     ${nst_result[0]}
    Set Suite Variable     ${nst_uuid}    ${nst_result[1]}
    Log     ${nst_uuid}
Network Slice Instantiation
    log     ${NSI_NAME}
    log     ${NSI_DESCRIPTION}
    ${date} = 	Get Current Date
    ${nsi_result} =    Slice Instantiate     ${nst_uuid}    name=${NSI_NAME}${date}    description=${NSI_DESCRIPTION}
    Log     ${nsi_result}
    Should Be True     ${nsi_result[0]}
    Set Suite Variable     ${nsi_inst_req_uuid}    ${nsi_result[1]}
    Log     ${nsi_inst_req_uuid}
Validates Instantiation Process
    Wait until Keyword Succeeds     7 min    30 sec    Check Instance Status
Network Slice Termination
    ${request_dict} =     Get Request    ${nsi_inst_req_uuid}  
    Log     ${request_dict}
    ${nsi_result} =    Slice Terminate     ${request_dict[1]['instance_uuid']}
    Log    ${nsi_result}
    Should Be True    ${nsi_result[0]}
    Set Suite Variable     ${nsi_term_req_uuid}    ${nsi_result[1]}
    Log     ${nsi_term_req_uuid}
Validate Termination Process
    Wait until Keyword Succeeds     5 min    5 sec    Check Terminate Status
Remove Network Slice Template
    Log     ${nst_uuid}
    ${nst_result} =   Delete Slice Template     ${nst_uuid}
    Log     ${nst_result}
    Should Be True     ${nst_result[0]}
Remove Service Package
    ${result}=    Remove Package    package_uuid=${PACKAGE_UUID}
    Log     ${result}
*** Keywords ***
Check Instance Status
    ${instance_dict} =     Get Request    ${nsi_inst_req_uuid}
    LOG    ${instance_dict}
    LOG    ${instance_dict[1]}
    Set Suite Variable     ${inst_nsir}    ${instance_dict[1]}
    LOG    ${inst_nsir}
    Should Be Equal    ${INSTANTIATED}    ${inst_nsir['status']}
Check Terminate Status
    ${terminate_dict} =     Get Request    ${nsi_term_req_uuid}
    LOG    ${terminate_dict}
    LOG    ${terminate_dict[1]}
    Set Suite Variable     ${term_nsir}    ${terminate_dict[1]}
    LOG    ${term_nsir}
    Should Be Equal    ${TERMINATED}    ${term_nsir['status']}