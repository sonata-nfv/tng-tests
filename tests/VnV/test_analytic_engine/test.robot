*** Settings ***
Documentation   Test suite for the VnV E2E test
Library         tnglib
Library         Collections
Library         DateTime

*** Variables ***
${VNV_HOST}     http://pre-int-vnv-bcn.5gtango.eu
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
    ${result} =     Get Latest Succesful Test Results
    Should Be True     ${result[0]}
    Set Suite Variable     ${TEST_RESULTS_UUID}  ${result[1]['uuid']}
    Log     ${TEST_RESULTS_UUID}
Fetch All Available Analytic Services
    ${result} =     Get Analytic Services
    Should Be True     ${result[0]}
    Log     ${result[1]}
    Should Be True    int(${result[1]}) > 6
Invoke a test analytic process
    ${result} =     Invoke Analytic Process      testr_uuid=${TEST_RESULTS_UUID}   service_name='filter_healthy_metrics'
    Should Be True     ${result}
Check Analytic results	
    ${result} =     Get Analytic Results
    Should Be True     ${result[0]}
    Should Be True    int(${result[1]}) > 0



*** Keywords ***
Check Request Status
    ${requests} =     Get Request     ${REQUEST}
    Should Be Equal    ${READY}  ${requests[1]['status']}
Check Test Result Status
    ${test_uuid} =     Get Test Uuid By Instance Uuid   ${INSTANCE_UUID}
    ${results} =    Get Test Result     ${test_uuid[1][0]['uuid']}
    Should Be Equal     ${PASSED}   ${results[1]['status']}
