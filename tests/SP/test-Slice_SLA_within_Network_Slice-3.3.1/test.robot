*** Settings ***
Documentation     Network Slice Test 3.3.1 - Slice with 3NS and SLA each one of them to ensure QoS.
Library           tnglib
Library           Collections
Library           DateTime
Library           OperatingSystem

*** Variables ***
#${SP_HOST}                 http://int-sp-ath.5gtango.eu   #  the name of SP we want to use
${FILE_SOURCE_DIR}         ./packages   # to be modified and added accordingly if package is not on the same folder as test
${NS_PACKAGE_NAME}         eu.5gtango.test-slice-vnfs.0.1.tgo    # The package to be uploaded and tested
${NS_PACKAGE_SHORT_NAME}   test-nsid1v
${FILE_TEMPLATE_PATH}      NSTD_VNF
${FILE_TEMPLATE_NAME}      3nsid1v_nstd.yml
${NSI_NAME}                sliceTest_331-
${NSI_DESCRIPTION}         Testing_slice_test_case_3.3.1
${sla_name}                int_test_1
${INSTANTIATED}            INSTANTIATED
${TERMINATED}              TERMINATED


*** Test Cases ***
Setting the SP Path
    Set SP Path     ${SP_HOST}
    ${result}=    Sp Health Check
    Should Be True   ${result}
Clean the Package Before Uploading
    @{PACKAGES}=   Get Packages
    FOR     ${PACKAGE}  IN  @{PACKAGES[1]}
        Run Keyword If     '${PACKAGE['name']}'== '${NS_PACKAGE_SHORT_NAME}'    Remove Package      ${PACKAGE['package_uuid']}
    END 
Upload the Package
    Log     ${FILE_SOURCE_DIR}
    Log     ${NS_PACKAGE_NAME}
    ${result}=    Upload Package      ${FILE_SOURCE_DIR}/${NS_PACKAGE_NAME}
    Log     ${result}
    Should Be True     ${result[0]}
    Set Suite Variable    ${PACKAGE_UUID}    ${result[1]}
    ${service}=    Map Package On Service    ${result[1]}
    Log     ${service}
    Should Be True    ${service[0]}
    Set Suite Variable    ${SERVICE_UUID}    ${service[1]}
    Log     ${SERVICE_UUID}
Generate the SLA Template
    ${result}=      Create Sla Template         templateName=${sla_name}   nsd_uuid=${SERVICE_UUID}   expireDate=20/12/2030   guaranteeId=g1   provider_name=UPRC   dflavour_name=    template_initiator=admin    provider_name=admin   service_licence_type=public   allowed_service_instances=5    service_licence_expiration_date=20/12/2030
    Set Suite Variable     ${SLA_UUID}   ${result[1]}
    Should be True      ${result[0]}
Create Instantiation JSON file
    ${yaml_file}=    Get File    ${FILE_SOURCE_DIR}/${FILE_TEMPLATE_PATH}/${FILE_TEMPLATE_NAME}  
    ${nstd_dict}=    Add Sla To Nstd Subnets    ${yaml_file}    ${SLA_UUID}    ${sla_name}
    Log    ${nstd_dict[1]}
    Should be True      ${nstd_dict[0]}
    ${json_string}=    Evaluate    json.dumps(${nstd_dict[1]})    json
    ${json_file}=    Create File    ${FILE_SOURCE_DIR}/${FILE_TEMPLATE_PATH}/test_nstd.json    ${json_string}
Upload the Slice Template
    Log    ${FILE_SOURCE_DIR}
    Log    ${FILE_TEMPLATE_PATH}
    ${nst_result} =    Create Slice Template     ${FILE_SOURCE_DIR}/${FILE_TEMPLATE_PATH}/test_nstd.json
    Log    ${nst_result}
    Should Be True     ${nst_result[0]}
    Set Suite Variable     ${nst_uuid}    ${nst_result[1]}
    Log    ${nst_uuid}
Deploy a Network Slice Instance
    Log     ${NSI_NAME}
    Log     ${NSI_DESCRIPTION}
    ${date}= 	Get Current Date
    ${nsi_result}=    Slice Instantiate     ${nst_uuid}    name=${NSI_NAME}${date}    description=${NSI_DESCRIPTION}
    Log     ${nsi_result}
    Should Be True     ${nsi_result[0]}
    Set Suite Variable     ${nsi_inst_req_uuid}    ${nsi_result[1]}
    Log     ${nsi_inst_req_uuid}
Wait For Instantiated
    Wait until Keyword Succeeds     7 min    30 sec    Check Instance Status
    Set SIU
Get Agreements
    ${result}=      Get Agreements    nsi_uuid=${slice_id}
    Should be True      ${result}
Terminate the Slice Instance
    Log     ${slice_id}
    ${nsi_result}=    Slice Terminate     ${slice_id}
    Log    ${nsi_result}
    Should Be True    ${nsi_result[0]}
    Set Suite Variable     ${nsi_term_req_uuid}    ${nsi_result[1]}
    Log     ${nsi_term_req_uuid}
Wait For Terminated
    Wait until Keyword Succeeds     5 min    30 sec    Check Terminate Status
Remove Slice Template
    Log     ${nst_uuid}
    ${nst_result}=   Delete Slice Template     ${nst_uuid}
    Log     ${nst_result}
    Should Be True     ${nst_result[0]}
Delete SLA
    ${result}=      Delete SlaTemplate    ${SLA_UUID}
    Should be True      ${result[0]}
Clean the Package
    ${result}=    Remove Package    ${PACKAGE_UUID}
Clean the NSTD json file
    ${remove_json_file}=    Remove File    ${FILE_SOURCE_DIR}/${FILE_TEMPLATE_PATH}/test_nstd.json

*** Keywords ***
Check Instance Status
    ${REQUEST_instance_dict}=     GET REQUEST    ${nsi_inst_req_uuid}
    LOG     ${REQUEST_instance_dict[1]['status']}
    Should Be Equal    ${INSTANTIATED}    ${REQUEST_instance_dict[1]['status']}
Check Terminate Status
    ${REQUEST_terminate_dict}=     GET REQUEST    ${nsi_term_req_uuid}
    LOG     ${REQUEST_terminate_dict[1]['status']}
    Should Be Equal    ${TERMINATED}    ${REQUEST_terminate_dict[1]['status']}
Set SIU
    ${status}=     Get Request    ${nsi_inst_req_uuid}
    Set Suite Variable    ${slice_id}    ${status[1]['instance_uuid']}