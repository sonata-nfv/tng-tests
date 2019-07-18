*** Settings ***
Documentation     Test suite template for deploy and undeploy
Library           tnglib
Library           Collections

*** Variables ***
${SP_HOST}      http://qual-sp-bcn.5gtango.eu
${FILE_SOURCE_DIR}  /home/paco/test/robot/packages
${NS_PACKAGE_NAME}  service.tgo
${NS_PACKAGE_SHORT_NAME}  ns-mediapilot-service
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
    ${service} =     Map Package On Service      ${result[1]}
    Should Be True     ${service[0]}
    Set Suite Variable     ${SERVICE_UUID}  ${service[1]}
    Log     ${SERVICE_UUID}
Deploying Service
    ${init} =   Service Instantiate     ${SERVICE_UUID}
    Log     ${init}
    Set Suite Variable     ${REQUEST}  ${init[1]}
    Log     ${REQUEST}    
Wait For Ready
    Wait until Keyword Succeeds     2 min   5 sec   Check Status
    Set SIU   
Terminate Service
    Log     ${TERMINATE}
    ${ter} =    Service Terminate   ${TERMINATE}
    Log     ${ter}
    Set Suite Variable     ${TERM_REQ}  ${ter[1]}
Wait For Terminate Ready    
    Wait until Keyword Succeeds     2 min   5 sec   Check Terminate   
Clean the Package after terminating
    @{PACKAGES} =   Get Packages
    FOR     ${PACKAGE}  IN  @{PACKAGES[1]}
        Run Keyword If     '${PACKAGE['name']}'== '${NS_PACKAGE_SHORT_NAME}'    Remove Package      ${PACKAGE['package_uuid']}
    END   



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
