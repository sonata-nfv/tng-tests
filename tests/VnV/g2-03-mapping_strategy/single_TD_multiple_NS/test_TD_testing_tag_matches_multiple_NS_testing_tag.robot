*** Settings ***
Documentation   Test suite for the VnV E2E test
Library         tnglib
Library         Collections
Library         DateTime
Library	        RequestsLibrary

*** Variables ***
${VNV_HOST}     http://pre-int-vnv-bcn.5gtango.eu
${SP_HOST}      http://qual-sp-bcn.5gtango.eu
${VnV_URL}      http://pre-int-vnv-bcn.5gtango.eu:6100/api/v1
${FILE_SOURCE_DIR}  ./packages
${NS_PACKAGE_NAME_1}  eu.5gtango.ns-nsid1v-1-td-tt-n-ns-tt-1.0.2.tgo
${NS_PACKAGE_NAME_2}  eu.5gtango.ns-nsid1v-1-td-tt-n-ns-tt-2.0.2.tgo
${TST_PACKAGE_NAME}  eu.5gtango.generic-probes-test-pingonly-single-td-multiple-ns.0.1.tgo
${NS_PACKAGE_SHORT_NAME_1}  ns-nsid1v-1-td-tt-n-ns-tt-1
${NS_PACKAGE_SHORT_NAME_2}  ns-nsid1v-1-td-tt-n-ns-tt-2
${TST_PACKAGE_SHORT_NAME}  generic-probes-test-pingonly-single-td-multiple-ns
${TEST_DESCRIPTOR_NAME}  test-generic-probes-single-td-multiple-ns
${READY}       READY
${PASSED}      PASSED
${TERMINATED}   terminated
${CREATE_SERVICE}       CREATE_SERVICE

*** Test Cases ***
Setting the VnV Path
    #From date to obtain GrayLogs
    ${from_date} =   Get Current Date
    Set Global Variable  ${from_date}
    Set SP Path     ${VNV_HOST}
    ${result} =     Sp Health Check
    Should Be True  ${result}
Clean the Packages
    @{PACKAGES} =   Get Packages
    FOR     ${PACKAGE}  IN  @{PACKAGES[1]}
        Run Keyword If     '${PACKAGE['name']}'== '${NS_PACKAGE_SHORT_NAME_1}' or '${PACKAGE['name']}'== '${NS_PACKAGE_SHORT_NAME_2}' or '${PACKAGE['name']}'== '${TST_PACKAGE_SHORT_NAME}'    Remove Package      ${PACKAGE['package_uuid']}
    END
Upload the NS Package
    ${result}=      Upload Package      ${FILE_SOURCE_DIR}/${NS_PACKAGE_NAME_1}
    Should Be True     ${result[0]}
    ${result}=      Upload Package      ${FILE_SOURCE_DIR}/${NS_PACKAGE_NAME_2}
    Should Be True     ${result[0]}
Upload the TST Package
    ${result}=      Upload Package      ${FILE_SOURCE_DIR}/${TST_PACKAGE_NAME}
    Log  ${result[1]}
    Should Be True     ${result[0]}

Wait For Service Instance 1 Ready
    #Setting the SP Path
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
    Sleep   60
    Wait until Keyword Succeeds     5 min   1 sec   Check Create Service Request
    ${request_list} =   Get Requests
    Set Suite Variable  ${REQUEST}  ${request_list[1][0]['request_uuid']}
    Wait until Keyword Succeeds     5 min   5 sec   Check Request Status

Wait For Test 1 Execution
    Set SP Path     ${VNV_HOST}
    Wait until Keyword Succeeds     20 min   5 sec   Check Test Result Status
#Setting the SP Path
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
    @{REQUESTS_LIST} =  Get Requests
    FOR    ${ELEMENT}  IN  @{REQUESTS_LIST[1]}
        Run Keyword If  '${ELEMENT['instance_uuid']}'== '${INSTANCE_UUID}' and '${ELEMENT['request_type']}'== 'TERMINATE_SERVICE'   Set Suite Variable   ${REQUEST}  ${ELEMENT['request_uuid']}
    END
    Wait until Keyword Succeeds     6 min   4 sec   Check Request Status

Wait For Service Instance 2 Ready
    #Setting the SP Path
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
    Sleep   60
    Wait until Keyword Succeeds     5 min   1 sec   Check Create Service Request
    ${request_list} =   Get Requests
    Set Suite Variable  ${REQUEST}  ${request_list[1][0]['request_uuid']}
    Wait until Keyword Succeeds     5 min   5 sec   Check Request Status
Wait For Test 2 Execution
    Set SP Path     ${VNV_HOST}
    Wait until Keyword Succeeds     20 min   5 sec   Check Test Result Status
#Setting the SP Path
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
    @{REQUESTS_LIST} =  Get Requests
    FOR    ${ELEMENT}  IN  @{REQUESTS_LIST[1]}
        Run Keyword If  '${ELEMENT['instance_uuid']}'== '${INSTANCE_UUID}' and '${ELEMENT['request_type']}'== 'TERMINATE_SERVICE'   Set Suite Variable   ${REQUEST}  ${ELEMENT['request_uuid']}
    END
    Wait until Keyword Succeeds     6 min   4 sec   Check Request Status
    #Sleep   60
    #${instance} =     Get Service Instance      ${INSTANCE_UUID}
    #Should Be Equal  ${TERMINATED}   ${instance[1]['status']}
Check Result Of Test Case
    Set SP Path     ${VNV_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}

    ${TEST_DESCRIPTOR_LIST} =  Get Test Descriptors
    Log  ${TEST_DESCRIPTOR_LIST}
    FOR     ${TEST_DESCRIPTOR}  IN  @{TEST_DESCRIPTOR_LIST[1]}
        Log  ${TEST_DESCRIPTOR}
        Run Keyword If     '${TEST_DESCRIPTOR['name']}'== '${TEST_DESCRIPTOR_NAME}'     Set Suite Variable  ${TEST_DESCRIPTOR_UUID}   ${TEST_DESCRIPTOR['uuid']}
    END
    Log  ${TEST_DESCRIPTOR_UUID}

    #Obtain NS descriptor UUID
    ${SERVICE_DESCRIPTOR_LIST} =  Get Service Descriptors
    Log  ${SERVICE_DESCRIPTOR_LIST}
    FOR     ${SERVICE_DESCRIPTOR}  IN  @{SERVICE_DESCRIPTOR_LIST[1]}
        Run Keyword If     '${SERVICE_DESCRIPTOR['name']}'== '${NS_PACKAGE_SHORT_NAME_1}'     Set Suite Variable  ${SERVICE_DESCRIPTOR_UUID_1}   ${SERVICE_DESCRIPTOR['descriptor_uuid']}
    END
    Log  ${SERVICE_DESCRIPTOR_UUID_1}

    ${SERVICE_DESCRIPTOR_LIST} =  Get Service Descriptors
    Log  ${SERVICE_DESCRIPTOR_LIST}
    FOR     ${SERVICE_DESCRIPTOR}  IN  @{SERVICE_DESCRIPTOR_LIST[1]}
        Run Keyword If     '${SERVICE_DESCRIPTOR['name']}'== '${NS_PACKAGE_SHORT_NAME_2}'     Set Suite Variable  ${SERVICE_DESCRIPTOR_UUID_2}   ${SERVICE_DESCRIPTOR['descriptor_uuid']}
    END
    Log  ${SERVICE_DESCRIPTOR_UUID_2}

    #Verify that both test plans have been created.
    ${TEST_PLAN_LIST} =  Get Test Plans
    Log  ${TEST_PLAN_LIST}
    Set Suite Variable  ${TEST_PLAN_1_EXISTS}   False
    FOR     ${TEST_PLAN}  IN  @{TEST_PLAN_LIST[1]}
        Run Keyword If     '${TEST_PLAN['test_uuid']}'== '${TEST_DESCRIPTOR_UUID}' and '${TEST_PLAN['service_uuid']}'== '${SERVICE_DESCRIPTOR_UUID_1}'   Set Suite Variable  ${TEST_PLAN_1_EXISTS}   True
    END
    Should Be Equal  ${TEST_PLAN_1_EXISTS}  True

    Set Suite Variable  ${TEST_PLAN_EXISTS}   False
    FOR     ${TEST_PLAN}  IN  @{TEST_PLAN_LIST[1]}
        Run Keyword If     '${TEST_PLAN['test_uuid']}'== '${TEST_DESCRIPTOR_UUID}' and '${TEST_PLAN['service_uuid']}'== '${SERVICE_DESCRIPTOR_UUID_2}'   Set Suite Variable  ${TEST_PLAN_2_EXISTS}   True
    END
    Should Be Equal  ${TEST_PLAN_2_EXISTS}  True

Obtain GrayLogs
    ${to_date} =  Get Current Date
    Set Suite Variable  ${param_file}   True
    Get Logs  ${from_date}  ${to_date}  ${VNV_HOST}  ${param_file}

*** Keywords ***
Check Create Service Request
    ${requests} =     Get Requests
    Should Be Equal     ${CREATE_SERVICE}   ${requests[1][0]['request_type']}
Check Request Status
    ${requests} =     tnglib.Get Request     ${REQUEST}
    Set Global Variable   ${INSTANCE_UUID}      ${requests[1]['instance_uuid']}
    Should Be Equal    ${READY}  ${requests[1]['status']}
Check Test Result Status
    ${test_uuid} =     Get Test Uuid By Instance Uuid   ${INSTANCE_UUID}
    ${results} =    Get Test Result     ${test_uuid[1][0]['uuid']}
    Should Be Equal     ${PASSED}   ${results[1]['status']}
