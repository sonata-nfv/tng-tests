*** Settings ***
Documentation   Test suite for the VnV E2E test
Library         tnglib
Library         Collections
Library         DateTime

*** Variables ***
${VNV_HOST}     http://int-vnv-bcn.5gtango.eu
${SP_HOST}      http://qual-sp-bcn.5gtango.eu
${FILE_SOURCE_DIR}  ./packages
${NS_PACKAGE_NAME}  eu.5gtango.test-ns-nsid1v_cirros_osm.0.1.tgo
${TST_PACKAGE_NAME}  eu.5gtango.generic-probes-test-pingonly-osm.0.1.tgo
${NS_PACKAGE_SHORT_NAME}  test-ns-nsid1v-cirros-osm
${TST_PACKAGE_SHORT_NAME}  generic-probes-test-pingonly-osm
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
    #@{PACKAGES} =   Get Packages
    #FOR     ${PACKAGE}  IN  @{PACKAGES[1]}
    #    Run Keyword If     '${PACKAGE['name']}'== '${NS_PACKAGE_SHORT_NAME}' or '${PACKAGE['name']}'== '${TST_PACKAGE_SHORT_NAME}'     Remove Package      ${PACKAGE['package_uuid']}
    #END
    Remove All Packages
Upload the NS Package
    ${result}=      Upload Package      ${FILE_SOURCE_DIR}/${NS_PACKAGE_NAME}
    Should Be True     ${result[0]}
Upload the TST Package
    ${result}=      Upload Package      ${FILE_SOURCE_DIR}/${TST_PACKAGE_NAME}
    Log  ${result[1]}
    Should Be True     ${result[0]}
Wait For Test Execution
    Set SP Path     ${VNV_HOST}
    #get test uuid from package
    @{TESTS} =    Get Test Descriptors
    FOR    ${TEST}    IN  @{TESTS[1]}
        Run Keyword If    '${TEST['name']}'== 'test-generic-probes-osm' and '${TEST['vendor']}'== 'eu.5gtango.optare' and '${TEST['version']}'== '0.1'    Set Global Variable   ${TEST_UUID}      ${TEST['uuid']}
    END
    Wait until Keyword Succeeds     20 min   5 sec   Check Test Result Status
Obtain GrayLogs
    ${to_date} =  Get Current Date
    Set Suite Variable  ${param_file}   True
    Get Logs  ${from_date}  ${to_date}  ${VNV_HOST}  ${param_file}

*** Keywords ***
Check Test Result Status
    ${plans} =    Get Test Plans
    FOR    ${plan}    IN  @{plans[1]}
        Run Keyword If    '${plan['test_uuid']}'== '${TEST_UUID}'    Set Suite Variable    ${TEST_RESULT_UUID}    ${plan['test_result_uuid']}
    END
    ${results} =    Get Test Result     ${TEST_RESULT_UUID}
    Should Be Equal     ${PASSED}   ${results[1]['status']}
