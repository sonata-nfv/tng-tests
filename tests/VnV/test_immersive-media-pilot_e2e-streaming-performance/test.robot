*** Settings ***
Documentation   Test suite for the VnV E2E test
Library         tnglib
Library         Collections

*** Variables ***
${VNV_HOST}     http://pre-int-vnv-bcn.5gtango.eu
${SP_HOST}      http://qual-sp-bcn.5gtango.eu
${FILE_SOURCE_DIR}  ./packages
${NS_PACKAGE_NAME}  eu.5gtango.ns-mediapilot-service-k8s.0.3.tgo
${TST_PACKAGE_NAME}  eu.5gtango.media-performance-test.0.1.tgo
${NS_PACKAGE_SHORT_NAME}  ns-mediapilot-service-k8s
${TST_PACKAGE_SHORT_NAME}  media-performance-test
${READY}       READY
${PASSED}      PASSED
${TERMINATED}   terminated

*** Test Cases ***
Setting the VnV Path
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
Wait For Service Instance Ready
    #Setting the SP Path
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
    Sleep   120
    ${request_list} =   Get Requests
    Set Suite Variable  ${REQUEST}  ${request_list[1][0]['request_uuid']}
    Set Global Variable  ${INSTANCE_UUID}    ${request_list[1][0]['instance_uuid']}
    Wait until Keyword Succeeds     5 min   5 sec   Check Request Status
Wait For Test Execution
    Set SP Path     ${VNV_HOST}
    Wait until Keyword Succeeds     10 min   5 sec   Check Test Result Status
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
    ${instance} =     Get Service Instance      ${INSTANCE_UUID}
    Should Be Equal  ${TERMINATED}   ${instance[1]['status']}

*** Keywords ***
Check Request Status
    ${requests} =     Get Request     ${REQUEST}
    Should Be Equal    ${READY}  ${requests[1]['status']}
Check Test Result Status
    ${test_uuid} =     Get Test Uuid By Instance Uuid   ${INSTANCE_UUID}
    ${results} =    Get Test Result     ${test_uuid[1][0]['uuid']}
    Should Be Equal     ${PASSED}   ${results[1]['status']}
