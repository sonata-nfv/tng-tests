*** Settings ***
Documentation   Test monitoring data collection
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
${CREATE_SERVICE}       CREATE_SERVICE
${INSTANCE_UUID}    2c70f324-a0b4-4917-aa85-a5dab6220094

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

Wait For Service Instance Ready
    #Setting the SP Path
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
    Sleep   120
    Wait until Keyword Succeeds     3 min   1 sec   Check Create Service Request
    ${request_list} =   Get Requests
    Set Suite Variable  ${REQUEST}  ${request_list[1][0]['request_uuid']}
    Wait until Keyword Succeeds     5 min   5 sec   Check Request Status

Retrieve list of monitoring metrics 
    @{VNFS} =     Get Services     ${INSTANCE_UUID}
    Should Be True    ${VNFS[0]}
    FOR     ${VNF}  IN  @{VNFS[1]}
        ${METRIC_LIST} =   Get Metrics      ${VNF['vnf_uuid']}    ${VNF['vdu_uuid']}
        ${LGH} =  Get Length  ${METRIC_LIST[1]}
        Should Be True    ${LGH} > 0
        Log    ${METRIC_LIST}
    END

Wait For Test Execution
    Set SP Path     ${VNV_HOST}
    Wait until Keyword Succeeds     20 min   5 sec   Check Test Result Status

Stop Collecting Monitoring Data
     ${resp} =    Stop monitoring    ${INSTANCE_UUID}

Retrieve Stored Monitoring Data
     ${DATA_SET} =   Get Vnv Tests    ${INSTANCE_UUID}
     Should Be True    ${DATA_SET[0]}

*** Keywords ***
Check Create Service Request
    ${requests} =     Get Requests
    Should Be Equal     ${CREATE_SERVICE}   ${requests[1][0]['request_type']}
Check Request Status
    ${requests} =     Get Request     ${REQUEST}
    Set Global Variable   ${INSTANCE_UUID}      ${requests[1]['instance_uuid']}
    Should Be Equal    ${READY}  ${requests[1]['status']}
Check Test Result Status
    ${plans} =    Get Test Plans
    FOR    ${plan}    IN  @{plans[1]}
        Run Keyword If    '${plan['test_uuid']}'== '${TEST_UUID}'    Set Suite Variable    ${TEST_RESULT_UUID}    ${plan['test_result_uuid']}
    END
    ${results} =    Get Test Result     ${TEST_RESULT_UUID}
    Should Be Equal     ${PASSED}   ${results[1]['status']}
