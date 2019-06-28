*** Settings ***
Documentation   Test suite for the VnV E2E test
Library         tnglib
Library         Collections
Library         DateTime

*** Variables ***
${VNV_HOST}     http://pre-int-vnv-bcn.5gtango.eu
${SP_HOST}      http://qual-sp-bcn.5gtango.eu
${FILE_SOURCE_DIR}  ./packages
${NS_PACKAGE_NAME}  eu.5gtango.ns-mediapilot-service.0.5.tgo
${TST_PACKAGE_NAME}  eu.5gtango.media-performance-test.0.1.tgo
${NS_PACKAGE_SHORT_NAME}  ns-mediapilot-service
${TST_PACKAGE_SHORT_NAME}  media-performance-test
${READY}       READY
${PASSED}      PASSED
${TERMINATED}   terminated

*** Test Cases ***
Setting the VnV Path
    #From date to obtain GrayLogs
    ${from_date} =   Get Current Date
    Set Global Variable  ${from_date}
    Set SP Path     ${VNV_HOST}
    ${result} =     Sp Health Check
    Should Be True  ${result}
Fetch Results of latest Test succesfull execution
###Fetch Results of latest Test succesfull execution code will go here once ready
Invoke a test analytic process
###Invoke a test analytic process code will go here once ready
Select a set of healthy test monitoring metrics	
###Select healthy metrics code will go here once ready


*** Keywords ***
Check Request Status
    ${requests} =     Get Request     ${REQUEST}
    Should Be Equal    ${READY}  ${requests[1]['status']}
Check Test Result Status
    ${test_uuid} =     Get Test Uuid By Instance Uuid   ${INSTANCE_UUID}
    ${results} =    Get Test Result     ${test_uuid[1][0]['uuid']}
    Should Be Equal     ${PASSED}   ${results[1]['status']}
