*** Settings ***
Documentation     Test suite template for deploy and undeploy with elasticity policy enforcement
Library           tnglib
Library           Collections

*** Variables ***
${SP_HOST}                http://int-sp-ath.5gtango.eu   #  the name of SP we want to use
${READY}       READY
${FILE_SOURCE_DIR}     ../../../packages   # to be modified and added accordingly if package is not on the same folder as test
${NS_PACKAGE_NAME}           eu.5gtango.ns-squid-haproxy.0.1.tgo    # The package to be uploaded and tested
${NS_PACKAGE_SHORT_NAME}  ns-squid-haproxy
${POLICIES_SOURCE_DIR}     ./policies   # to be modified and added accordingly if policy is not on the same folder as test
${POLICY_NAME}           NS-squid-haproxy-Elasticity-Policy-Premium.json    # The policy to be uploaded and tested
${READY}       READY
${PASSED}      PASSED

*** Test Cases ***
Setting the SP Path
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
    Sleep   30
Define Runtime Policy as Default
    ${result} =     Define Policy As Default      ${POLICY_UUID}   service_uuid=${SERVICE_UUID}
    Should Be True     ${result[0]}
Deploying Service
    ${init} =   Service Instantiate     ${SERVICE_UUID}
    Log     ${init}
    Set Suite Variable     ${REQUEST}  ${init[1]}
    Log     ${REQUEST}    
Wait For Ready
    Wait until Keyword Succeeds     3 min   5 sec   Check Status
    Set SIU
Check monitoring rules
    ${result} =     Get Policy Rules      ${SERVICE_INSTANCE_UUID}
    Should Be True     ${result[0]}
    Should Be Equal    ${result[1]}  3
Trigger one Monitoring rule
### fake the custom metric crossing the threshold by placing it on the pushgateway.code will go here once ready
Check that scaling action has been triggered by the policy manager
###code will go here once ready.
Evaluate the outcome of the MANO action
###code will go here once ready
Terminate Service
    Log     ${TERMINATE}
    ${ter} =    Service Terminate   ${TERMINATE}
    Log     ${ter}
    Set Suite Variable     ${TERM_REQ}  ${ter[1]}
Wait For Terminate Ready    
    Wait until Keyword Succeeds     2 min   5 sec   Check Terminate  
Delete Runtime Policy
    ${result} =     Delete Policy      ${POLICY_UUID}
    Should Be True     ${result[0]}
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
