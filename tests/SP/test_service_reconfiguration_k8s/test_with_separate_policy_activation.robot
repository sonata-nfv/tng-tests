*** Settings ***
Documentation     Test suite template for deploy and undeploy of a NS composed of one cnf with elasticity policy enforcement
Library           tnglib
Library           Collections
Library           DateTime

*** Variables ***
${SP_HOST}                http://pre-int-sp-ath.5gtango.eu   #  the name of SP we want to use
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

*** Test Cases ***
Setting the SP Path
    #From date to obtain GrayLogs
    ${from_date} =   Get Current Date
    Set Global Variable  ${from_date}
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
Clean the Package Before Uploading
    @{PACKAGES} =   Get Packages
    FOR     ${PACKAGE}  IN  @{PACKAGES[1]}
        Run Keyword If     '${PACKAGE['name']}'== '${NS_PACKAGE_SHORT_NAME}'    Remove Package      ${PACKAGE['package_uuid']}
    END 
Upload the NS Package
    log     ${FILE_SOURCE_DIR}
    log     ${NS_PACKAGE_NAME}
    ${result} =      Upload Package     ${FILE_SOURCE_DIR}/${NS_PACKAGE_NAME}
    Log     ${result}
    Should Be True     ${result[0]}
    Set Suite Variable     ${PACKAGE_UUID}  ${result[1]}
    Log     ${PACKAGE_UUID}
    ${service} =     Map Package On Service      ${result[1]}
    Should Be True     ${service[0]}
    Set Suite Variable     ${SERVICE_UUID}  ${service[1]}
    Log     ${SERVICE_UUID}
Create Runtime Policy
    ${result} =     Create Policy      ${POLICIES_SOURCE_DIR}/${POLICY_NAME}
    Should Be True     ${result[0]}
    Set Suite Variable     ${POLICY_UUID}  ${result[1]}
Deploying Service
    ${init} =   Service Instantiate     ${SERVICE_UUID}
    Log     ${init}
    Set Suite Variable     ${REQUEST}  ${init[1]}
    Log     ${REQUEST}
Wait For Ready
    Wait until Keyword Succeeds     10 min   5 sec   Check Status
    Set SIU
Get Service Instance
    ${init} =   Get Request   ${REQUEST}
    Log     ${init}
    Set Suite Variable     ${SERVICE_INSTANCE_UUID}  ${init[1]['instance_uuid']}
    Log     ${SERVICE_INSTANCE_UUID} 
Activate Runtime Policy
    ${result} =     Activate Policy      ${SERVICE_INSTANCE_UUID}  ${POLICY_UUID}
    Should Be True     ${result[0]}
#Check monitoring rules
#    ${result} =     Get Policy Rules      ${SERVICE_INSTANCE_UUID}
#    Should Be True     ${result[0]}
#    Should Be Equal    ${result[1]}  1
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
    Should Be True    int(${result[1]}) > 3
Terminate Service
    ${ter} =    Service Terminate   ${SERVICE_INSTANCE_UUID}
    Log     ${ter}
    Set Suite Variable     ${TERM_REQ}  ${ter[1]}
Wait For Terminate Ready    
    Wait until Keyword Succeeds     3 min   5 sec   Check Terminate 
Delete Runtime Policy
    ${result} =     Delete Policy      ${POLICY_UUID}
    Should Be True     ${result[0]}
Remove the Package
    ${result} =     Remove Package      ${PACKAGE_UUID}
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
