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
${NS_PACKAGE_NAME}  eu.5gtango.test-ns-nsid1v-sonata-no-tags.0.2.tgo
${TST_PACKAGE_NAME}  eu.5gtango.generic-probes-test-pingonly-2-instances-probes.0.1.tgo
${NS_PACKAGE_SHORT_NAME}  test-ns-nsid1v-sonata-no-tags
${TST_PACKAGE_SHORT_NAME}  generic-probes-test-pingonly-2-instances-probes
${TEST_DESCRIPTOR_NAME}  test-generic-probes-2-instances
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
        Run Keyword If     '${PACKAGE['name']}'== '${NS_PACKAGE_SHORT_NAME}' or '${PACKAGE['name']}'== '${TST_PACKAGE_SHORT_NAME}'     Remove Package      ${PACKAGE['package_uuid']}
    END
Upload the NS Package
    ${result}=      Upload Package      ${FILE_SOURCE_DIR}/${NS_PACKAGE_NAME}
    Should Be True     ${result[0]}
Upload the TST Package
    ${result}=      Upload Package      ${FILE_SOURCE_DIR}/${TST_PACKAGE_NAME}
    Log  ${result[1]}
    Should Be True     ${result[0]}
Create Test Plan By Test Uuid And Service Uuid
    #Obtain TD UUID based on the name of TD: test-generic-probes-2-instances
    ${TEST_DESCRIPTOR_LIST} =  Get Test Descriptors
    Log  ${TEST_DESCRIPTOR_LIST}
    Log  ${TEST_DESCRIPTOR_LIST[1]}
    FOR     ${TEST_DESCRIPTOR}  IN  @{TEST_DESCRIPTOR_LIST[1]}
        Log  ${TEST_DESCRIPTOR}
        Run Keyword If     '${TEST_DESCRIPTOR['name']}'== '${TEST_DESCRIPTOR_NAME}'     Set Suite Variable  ${TEST_DESCRIPTOR_UUID}   ${TEST_DESCRIPTOR['uuid']}
    END
    Log  ${TEST_DESCRIPTOR_UUID}
    #Obtain NS descriptor UUID: test-ns-nsid1v-sonata-no-tags
    ${SERVICE_DESCRIPTOR_LIST} =  Get Service Descriptors
    Log  ${SERVICE_DESCRIPTOR_LIST}
    FOR     ${SERVICE_DESCRIPTOR}  IN  @{SERVICE_DESCRIPTOR_LIST[1]}
        Run Keyword If     '${SERVICE_DESCRIPTOR['name']}'== '${NS_PACKAGE_SHORT_NAME}'     Set Global Variable  ${SERVICE_DESCRIPTOR_UUID}   ${SERVICE_DESCRIPTOR['descriptor_uuid']}
    END
    Log  ${SERVICE_DESCRIPTOR_UUID}

    Create Session    urlVnV    ${VnV_URL}
    ${resp}=    Post Request  urlVnV  /test-plans/testAndServices?confirmRequired=false&serviceUuid=${SERVICE_DESCRIPTOR_UUID}&testUuid=${TEST_DESCRIPTOR_UUID}
    Log  ${resp}
    Should Be Equal As Strings	${resp.status_code}	 200
Wait For Service Instance Ready
    #Setting the SP Path
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
    Sleep   60
    Wait until Keyword Succeeds     3 min   1 sec   Check Create Service Request
    ${request_list} =   Get Requests
    Set Suite Variable  ${REQUEST}  ${request_list[1][0]['request_uuid']}
    Wait until Keyword Succeeds     5 min   5 sec   Check Request Status

Wait For Test Execution
    #Register start time of test plan to know how long it takes to execute.
    ${start_date_test_plan} =   Get Current Date
    Set Global Variable  ${start_date_test_plan}
    Set SP Path     ${VNV_HOST}
    #get test uuid from package
    @{TESTS} =    Get Test Descriptors
    FOR    ${TEST}    IN  @{TESTS[1]}
        Run Keyword If    '${TEST['name']}'== 'test-generic-probes-2-instances' and '${TEST['vendor']}'== 'eu.5gtango.optare' and '${TEST['version']}'== '0.1'    Set Global Variable   ${TEST_UUID}      ${TEST['uuid']}
    END
    Wait until Keyword Succeeds     20 min   5 sec   Check Test Result Status
Check No Running Instances
    #Register end time of test plan to know how long it takes to execute.
    ${end_date_test_plan} =   Get Current Date
    Set Global Variable  ${end_date_test_plan}
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

Retrigger Test Plan
    Set SP Path     ${VNV_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}

    ${TEST_DESCRIPTOR_LIST} =  Get Test Descriptors
    Log  ${TEST_DESCRIPTOR_LIST}
    FOR     ${TEST_DESCRIPTOR}  IN  @{TEST_DESCRIPTOR_LIST[1]}
        Log  ${TEST_DESCRIPTOR}
        Run Keyword If     '${TEST_DESCRIPTOR['name']}'== '${TEST_DESCRIPTOR_NAME}'     Set Suite Variable  ${TEST_DESCRIPTOR_UUID}   ${TEST_DESCRIPTOR['uuid']}
    END
    Log  ${TEST_DESCRIPTOR_UUID_}

    #Obtain NS descriptor UUID: test-ns-nsid1v-sonata-no-tags
    ${SERVICE_DESCRIPTOR_LIST} =  Get Service Descriptors
    Log  ${SERVICE_DESCRIPTOR_LIST}
    FOR     ${SERVICE_DESCRIPTOR}  IN  @{SERVICE_DESCRIPTOR_LIST[1]}
        Run Keyword If     '${SERVICE_DESCRIPTOR['name']}'== '${NS_PACKAGE_SHORT_NAME}'     Set Suite Variable  ${SERVICE_DESCRIPTOR_UUID}   ${SERVICE_DESCRIPTOR['descriptor_uuid']}
    END
    Log  ${SERVICE_DESCRIPTOR_UUID}

    #Verify that both test plans have been created.
    ${TEST_PLAN_LIST} =  Get Test Plans
    Log  ${TEST_PLAN_LIST}
    FOR     ${TEST_PLAN}  IN  @{TEST_PLAN_LIST[1]}
        Run Keyword If     '${TEST_PLAN['test_uuid']}'== '${TEST_DESCRIPTOR_UUID}' and '${TEST_PLAN['service_uuid']}'== '${SERVICE_DESCRIPTOR_UUID}' and '${TEST_PLAN['status']}'== 'COMPLETED'   Set Suite Variable  ${TEST_PLAN_UUID}   ${TEST_PLAN['uuid']}
    END
    Log  ${TEST_PLAN_UUID}

    Create Session    urlVnV    ${VnV_URL}
    ${resp}=    Put Request  urlVnV  /test-plans/${TEST_PLAN_UUID}?status=RETRIED
    Log  ${resp}
    Should Be Equal As Strings	${resp.status_code}	 200
Wait For Service Instance Ready Retriggered Test Plan
    #Setting the SP Path
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
    Sleep   60
    Wait until Keyword Succeeds     3 min   1 sec   Check Create Service Request
    ${request_list} =   Get Requests
    Set Suite Variable  ${REQUEST}  ${request_list[1][0]['request_uuid']}
    Wait until Keyword Succeeds     5 min   5 sec   Check Request Status

Wait For Test Execution Retriggered Test Plan
    Set SP Path     ${VNV_HOST}
    #get test uuid from package
    @{TESTS} =    Get Test Descriptors
    FOR    ${TEST}    IN  @{TESTS[1]}
        Run Keyword If    '${TEST['name']}'== 'test-generic-probes-2-instances' and '${TEST['vendor']}'== 'eu.5gtango.optare' and '${TEST['version']}'== '0.1'    Set Global Variable   ${TEST_UUID}      ${TEST['uuid']}
    END
    Wait until Keyword Succeeds     20 min   5 sec   Check Test Result Status
Check No Running Instances Retriggered Test Plan
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
        Run Keyword If     '${SERVICE_DESCRIPTOR['name']}'== '${NS_PACKAGE_SHORT_NAME}'     Set Suite Variable  ${SERVICE_DESCRIPTOR_UUID}   ${SERVICE_DESCRIPTOR['descriptor_uuid']}
    END
    Log  ${SERVICE_DESCRIPTOR_UUID}

    #Verify that one test plan has status RETRIED and the other one completed.
    ${TEST_PLAN_LIST} =  Get Test Plans
    Log  ${TEST_PLAN_LIST}
    Set Suite Variable  ${TEST_PLAN_RETRIED_EXISTS}   False
    FOR     ${TEST_PLAN}  IN  @{TEST_PLAN_LIST[1]}
        Run Keyword If     '${TEST_PLAN['test_uuid']}'== '${TEST_DESCRIPTOR_UUID}' and '${TEST_PLAN['service_uuid']}'== '${SERVICE_DESCRIPTOR_UUID}' and '${TEST_PLAN['status']}'== 'RETRIED'   Set Suite Variable  ${TEST_PLAN_RETRIED_EXISTS}   True
    END
    Log  ${TEST_PLAN_RETRIED_EXISTS}
    Should Be Equal  ${TEST_PLAN_RETRIED_EXISTS}  True

    Set Suite Variable  ${TEST_PLAN_COMPLETED_EXISTS}   False
    FOR     ${TEST_PLAN}  IN  @{TEST_PLAN_LIST[1]}
        Run Keyword If     '${TEST_PLAN['test_uuid']}'== '${TEST_DESCRIPTOR_UUID}' and '${TEST_PLAN['service_uuid']}'== '${SERVICE_DESCRIPTOR_UUID}' and '${TEST_PLAN['status']}'== 'COMPLETED'   Set Suite Variable  ${TEST_PLAN_COMPLETED_EXISTS}   True
    END
    Should Be Equal  ${TEST_PLAN_COMPLETED_EXISTS}  True
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
    ${plans} =    Get Test Plans
    FOR    ${plan}    IN  @{plans[1]}
        Run Keyword If    '${plan['test_uuid']}'== '${TEST_UUID}'    Set Suite Variable    ${TEST_RESULT_UUID}    ${plan['test_result_uuid']}
    END
    ${results} =    Get Test Result     ${TEST_RESULT_UUID}
    Should Be Equal     ${PASSED}   ${results[1]['status']}
