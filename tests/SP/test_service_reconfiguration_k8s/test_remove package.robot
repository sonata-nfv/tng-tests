*** Settings ***
Documentation     Test suite template for deploy and undeploy of a NS composed of one cnf with elasticity policy enforcement
Library           tnglib
Library           Collections
Library           DateTime

*** Variables ***
${SP_HOST}                http://int-sp-ath.5gtango.eu   #  the name of SP we want to use
${READY}       READY
${FILE_SOURCE_DIR}     ../../../packages   # to be modified and added accordingly if package is not on the same folder as test (../../../packages from local pc)
${NS_PACKAGE_NAME}           eu.5gtango.ns-mediapilot-service.0.5.tgo    # The package to be uploaded and tested
${NS_PACKAGE_SHORT_NAME}  ns-mediapilot-service
${POLICIES_SOURCE_DIR}   ./policies   # to be modified and added accordingly if policy is not on the same folder as test ( ./policies from local pc)
${POLICY_NAME}           ns-mediapilot-service-sample-policy.json    # The policy to be uploaded and tested
${READY}       READY
${PASSED}      PASSED
${SERVICE_INSTANCE_UUID}    3565db24-bf67-498a-845e-29c856173b00  
${POLICY_UUID}   15af0439-56d6-409a-9a6f-90d8691de334
${PACKAGE_UUID}   60f7c947-8fd0-469e-975d-1d0a8242dbcc

*** Test Cases ***
Setting the SP Path
    #From date to obtain GrayLogs
    ${from_date} =   Get Current Date
    Set Global Variable  ${from_date}
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
Remove the Package
    ${result} =     Remove Package      ${PACKAGE_UUID}
    Should Be True     ${result[0]}


*** Keywords ***
Check Status
    ${status} =     Get Request     ${REQUEST}
    Should Be Equal    ${READY}  ${status[1]['status']}
Set SIU
    ${status} =     Get Request     ${REQUEST}
    Set Suite Variable     ${TERMINATE}    ${status[1]['instance_uuid']}
Check Terminate
    ${status} =     Get Request     ${TERM_REQ}
    Should Be Equal    ${READY}  ${status[1]['status']}
