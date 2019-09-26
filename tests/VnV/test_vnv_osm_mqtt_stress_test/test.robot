*** Settings ***
Documentation   Test suite for the MQTT broker stress test
Library         tnglib
Library         Collections
Library         DateTime

*** Variables ***
${VNV_HOST}     http://int-vnv.5gtango.eu
${SP_HOST}      http://172.31.8.163
${FILE_SOURCE_DIR}  ./packages
${NS_PACKAGE_NAME}  eu.5gtango.egm.mqtt-osm-cloud-init.0.1.tgo
${TST_PACKAGE_NAME}  eu.5gtango.egm.mqtt-osm-stress-test.0.9.tgo
${NS_PACKAGE_SHORT_NAME}  mqtt-osm-cloud-init
${TST_PACKAGE_SHORT_NAME}  mqtt-osm-stress-test
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
    Should Be True     ${result[0]}
Wait For Service Instance Ready
    Set SP Path     ${VNV_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
    Sleep   120
    ${request_list} =   Get Requests
    Set Suite Variable  ${REQUEST}  ${request_list[1][0]['request_uuid']}
    Wait until Keyword Succeeds     5 min   5 sec   Check Request Status
Wait For Test Execution
    Set SP Path     ${VNV_HOST}
    Wait until Keyword Succeeds     20 min   5 sec   Check Test Result Status
Obtain GrayLogs
    ${to_date} =  Get Current Date
    Set Suite Variable  ${param_file}   True
    Get Logs  ${from_date}  ${to_date}  ${VNV_HOST}  ${param_file}

*** Keywords ***
Check Create Service Request
    ${requests} =     Get Requests
    Should Be Equal     ${CREATE_SERVICE}   ${requests[1][0]['request_type']}
Check Request Status
    ${requests} =     Get Request     ${REQUEST}
    Set Global Variable   ${INSTANCE_UUID}      ${requests[1]['instance_uuid']}
    Should Be Equal    ${READY}  ${requests[1]['status']}
Check Test Result Status
    ${test_uuid} =     Get Test Uuid By Instance Uuid   ${INSTANCE_UUID}
    ${results} =    Get Test Result     ${test_uuid[1][0]['uuid']}
    Should Be Equal     ${PASSED}   ${results[1]['status']}
