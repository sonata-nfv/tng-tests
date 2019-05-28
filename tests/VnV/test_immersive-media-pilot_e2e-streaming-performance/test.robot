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
    ${request_list} =     Get Requests
    Log     ${request_list[1][1]['request_uuid']}
    Set Suite Variable  ${REQUEST}  ${request_list[1][1]['request_uuid']}
    Set Suite Variable  ${INSTANCE_UUID}    ${request_list[1][1]['instance_uuid']}
    Wait until Keyword Succeeds     5 min   Check Request Status
Wait For Test Execution
    Set SP Path     ${VNV_HOST}
    Wait until Keyword Succeeds     10 min   5 sec   Check Test Result Status
Check No Running Instances
#Setting the SP Path
    Sleep 60s
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
    ${instance} =     Get Service Instance      ${INSTANCE_UUID}
    Should Be Empty     ${instance}

*** Keywords ***
Check Request Status
    ${requests} =     Get Request     ${REQUEST}
    Should Be Equal    ${READY}  ${requests[1]['status']}
Check Test Result Status
    ${results} =     Get Test Uuid By Instance Uuid   ${INSTANCE_UUID}
    Should Be Equal     ${PASSED}   ${results[1][1]['status']}
