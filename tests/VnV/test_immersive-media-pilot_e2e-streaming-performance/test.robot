*** Settings ***
Documentation   Test suite for the VnV E2E test
Library         tnglib

*** Variables ***
${VNV_HOST}     http://pre-int-vnv-bcn.5gtango.eu
${SP_HOST}      http://pre-int-sp-ath.5gtango.eu
${FILE_SOURCE_DIR}  ./packages
${NS_PACKAGE_NAME}  eu.5gtango.ns-mediapilot-service-k8s.0.3.tgo
${TST_PACKAGE_NAME}  eu.5gtango.media-performance-test.0.1.tgo
${READY}       READY
${PASSED}      PASSED

*** Test Cases ***
Setting the VnV Path
    Set SP Path     ${VNV_HOST}
    ${result} =     Sp Health Check
    Should Be True  ${result}
Clean the Packages
    Remove all Packages
Upload the NS Package
    ${result}=      Upload Package      ${NS_PACKAGE_NAME}
    Should Be True     ${result[0]}
Upload the TST Package
    ${result}=      Upload Package      ${TST_PACKAGE_NAME}
    Log  ${result[1]}
    Should Be True     ${result[0]}
Wait For Service Instance Ready
    #Setting the SP Path
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
    ${request} = Get Requests
    Log     ${requests[1][1]['request_uuid']}
    Set Suite Variable  ${REQUEST}  ${request[1][1]['request_uuid']}
    Set Suite Variable  ${INSTANCE_UUID}    ${request[1][1]['instance_uuid']}
    Wait until Keyword Succeeds     3 min   5 sec   Check Request Status
Wait For Test Execution
    Set SP Path     ${VNV_HOST}
    ${test_uuid} = Get Test Uuid By Instance Uuid   ${INSTANCE_UUID}
    Log     ${test_uuid[1]['test_uuid']}
    Set Suite Variable  ${UUID}  ${test_uuid[1]['uuid']}
    Wait until Keyword Succeeds     3 min   5 sec   Check Test Result Status
Check No Running Instances
#Setting the SP Path
    sleep 60
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
    ${instances} = Get Service Instances
    Should Be Empty     ${instances}

*** Keywords ***
Check Request Status
    ${requests} =     Get Request     ${REQUEST}
    Should Be Equal    ${READY}  ${requests[1]['status']}
Check Test Result Status
    ${results} =     Get Test Result    ${UUID}
    Should Be Equal     ${PASSED}   ${results[1][1]['status']}
