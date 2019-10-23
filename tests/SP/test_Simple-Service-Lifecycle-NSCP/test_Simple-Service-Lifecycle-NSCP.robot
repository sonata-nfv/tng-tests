*** Settings ***
Documentation     Test suite template for deploy and undeploy with elasticity policy enforcement at Opestack
Library           tnglib
Library           Collections
Library           DateTime

*** Variables ***
${SP_HOST}                http://demo-comm-sp.5gtango.eu   #  the name of SP we want to use
${READY}       READY
${POLICIES_SOURCE_DIR}   ./policies   # to be modified and added accordingly if policy is not on the same folder as test ( ./policies from local pc)
${POLICY_NAME}           comm-pilot-Elasticity-Policy-Basic.json    # The policy to be uploaded and tested
${READY}       READY
${PASSED}      PASSED
${SERVICE_INSTANCE_UUID}  5fc4891f-cb2d-4cc6-b281-abda4b6a1d16

*** Test Cases ***
Setting the SP Path
    #From date to obtain GrayLogs
    ${from_date} =   Get Current Date
    Set Global Variable  ${from_date}
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
Create Runtime Policy
    ${result} =     Create Policy      ${POLICIES_SOURCE_DIR}/${POLICY_NAME}
    Should Be True     ${result[0]}
    Set Suite Variable     ${POLICY_UUID}  ${result[1]}
    Should Be True     ${result[0]} 
Αctivate Runtime Policy
    ${result} =     Enforce Policy      ${SERVICE_INSTANCE_UUID}   ${POLICY_UUID} 
    Should Be True     ${result[0]}
Wait for monitoring rules satisfaction
    Sleep   100s
Check that scaling action has been triggered by the policy manager
    ${result} =     Get Policy action   ${SERVICE_INSTANCE_UUID}
    Should Be True     ${result[0]}
    Should Be True     ${result[1]}
Deactivate Runtime Policy
    ${result} =     Deactivate Policy      ${SERVICE_INSTANCE_UUID}
    Should Be True     ${result[0]}
Wait for Mano execution of elasticity action
    Sleep   180s
Check that Mano has succesfully scaled out requested vnf
    ${result} =     Get Service vnfrs   ${SERVICE_INSTANCE_UUID}
    Should Be True     ${result[0]}
    Should Be True    int(${result[1]}) > 5
Delete Runtime Policy
    ${result} =     Delete Policy      ${POLICY_UUID}
    Should Be True     ${result[0]}
Obtain GrayLogs
    ${to_date} =  Get Current Date
    Set Suite Variable  ${param_file}   True
    Get Logs  ${from_date}  ${to_date}  ${SP_HOST}  ${param_file}

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
