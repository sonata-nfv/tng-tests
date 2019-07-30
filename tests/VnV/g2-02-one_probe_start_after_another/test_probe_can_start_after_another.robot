*** Settings ***
Documentation   Test suite for the VnV E2E test
Library         tnglib
Library         Collections
Library         DateTime
Library	        RequestsLibrary
Library         String

*** Variables ***
${VNV_HOST}     http://pre-int-vnv-bcn.5gtango.eu
${SP_HOST}      http://qual-sp-bcn.5gtango.eu
${VnV_URL}      http://pre-int-vnv-bcn.5gtango.eu:6100/api/v1
${FILE_SOURCE_DIR}  ./packages
${NS_PACKAGE_NAME}  eu.5gtango.test-ns-nsid1v-sonata-no-tags.0.2.tgo
${TST_PACKAGE_NAME}  eu.5gtango.generic-probes-test-pingonly-dependency-2-probes.0.1.tgo
${NS_PACKAGE_SHORT_NAME}  test-ns-nsid1v-sonata-no-tags
${TST_PACKAGE_SHORT_NAME}  generic-probes-test-pingonly-dependency-2-probes
${TEST_DESCRIPTOR_NAME}  test-generic-probes-dependency
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
    #Obtain TD UUID based on the name of TD: test-generic-probes-dependency
    ${TEST_DESCRIPTOR_LIST} =  Get Test Descriptors
    Log  ${TEST_DESCRIPTOR_LIST}
    Log  ${TEST_DESCRIPTOR_LIST[1]}
    FOR     ${TEST_DESCRIPTOR}  IN  @{TEST_DESCRIPTOR_LIST[1]}
        Log  ${TEST_DESCRIPTOR}
        Run Keyword If     '${TEST_DESCRIPTOR['name']}'== '${TEST_DESCRIPTOR_NAME}'     Set Suite Variable  ${TEST_DESCRIPTOR_UUID}   ${TEST_DESCRIPTOR['uuid']}
    END
    Log  ${TEST_DESCRIPTOR_UUID}
    #Obtain NS descriptor UUID: ns-mediapilot-service-no-tags
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
    Wait until Keyword Succeeds     5 min   1 sec   Check Create Service Request
    ${request_list} =   Get Requests
    Set Suite Variable  ${REQUEST}  ${request_list[1][0]['request_uuid']}
    Wait until Keyword Succeeds     5 min   5 sec   Check Request Status

Wait For Test Execution
    Set SP Path     ${VNV_HOST}
    Wait until Keyword Succeeds     20 min   5 sec   Check Test Result Status
Check No Running Instances
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
   Should Be True  ${result}
   #Get test descriptor UUID based on test descriptor name.
   ${TEST_DESCRIPTOR_LIST} =  Get Test Descriptors
   Log  ${TEST_DESCRIPTOR_LIST}
   Log  ${TEST_DESCRIPTOR_LIST[1]}
   FOR     ${TEST_DESCRIPTOR}  IN  @{TEST_DESCRIPTOR_LIST[1]}
       Run Keyword If     '${TEST_DESCRIPTOR['name']}'== '${TEST_DESCRIPTOR_NAME}'     Set Suite Variable  ${TEST_DESCRIPTOR_UUID}   ${TEST_DESCRIPTOR['uuid']}
   END
   Log  ${TEST_DESCRIPTOR_UUID}
   #Obtain test plan result uuid based on the test descriptor UUID.
   ${TEST_PLAN_LIST} =  Get Test Plans
   Log  ${TEST_PLAN_LIST}
   FOR     ${TEST_PLAN}  IN  @{TEST_PLAN_LIST[1]}
       Run Keyword If     '${TEST_PLAN['test_uuid']}'== '${TEST_DESCRIPTOR_UUID}'     Set Suite Variable  ${TEST_RESULT_UUID}   ${TEST_PLAN['test_result_uuid']}
   END
   Log  ${TEST_RESULT_UUID}

    ${TEST_RESULT} =  Get Test Result  ${TEST_RESULT_UUID}
    Log  ${TEST_RESULT[1]['results']}

    # A loop should be implemented to obtain the results for the different probes.
    Set Suite Variable  ${RESULT_PROBE_PING}   ${TEST_RESULT[1]['results'][0]['ping']}
    Set Suite Variable  ${RESULT_PROBE_NETCAT}   ${TEST_RESULT[1]['results'][1]['netcat']}
    Log  ${RESULT_PROBE_PING}
    Log  ${RESULT_PROBE_NETCAT}

    ${RESULT_PROBE_NETCAT_STR} =  Convert To String	 ${RESULT_PROBE_NETCAT}
    #Obtains the string: ["netcat starts: 1564473111563763185
    ${RESULT_PROBE_NETCAT_STR_TEMP} =  Fetch From Left  ${RESULT_PROBE_NETCAT_STR}  \\n
    Log  ${RESULT_PROBE_NETCAT_STR_TEMP}
    #Obtain only the timestamp
    ${RESULT_PROBE_NETCAT_TIMESTAMP} =  Fetch From Right  ${RESULT_PROBE_NETCAT_STR_TEMP}  ['netcat starts:
    Log  ${RESULT_PROBE_NETCAT_TIMESTAMP}

    ${RESULT_PROBE_PING_STR} =  Convert To String	 ${RESULT_PROBE_PING}
    #Obtains the string: 1564473114198722192\n']
    ${RESULT_PROBE_PING_STR_TEMP} =  Fetch From Right  ${RESULT_PROBE_PING_STR}  \\nping ends:
    Log  ${RESULT_PROBE_PING_STR_TEMP}
    #Obtain only the timestamp
    ${RESULT_PROBE_PING_TIMESTAMP} =  Fetch From Left  ${RESULT_PROBE_PING_STR_TEMP}  \\n']
    Log  ${RESULT_PROBE_PING_TIMESTAMP}

    Should Be True     ${RESULT_PROBE_NETCAT_TIMESTAMP.strip()} > ${RESULT_PROBE_PING_TIMESTAMP.strip()}
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
