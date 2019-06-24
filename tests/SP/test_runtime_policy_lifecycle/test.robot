*** Settings ***
Documentation     Test suite for enforcing a Runtime Policy to the SP platform
Library           tnglib

*** Variables ***
${HOST}                http://int-sp-ath.5gtango.eu   #  the name of SP we want to use
${READY}       READY
${FILE_SOURCE_DIR}     ./packages   # to be modified and added accordingly if package is not on the same folder as test
${FILE_NAME}           eu.5gtango.ns-squid-haproxy.0.1.tgo    # The package to be uploaded and tested
${POLICIES_SOURCE_DIR}     ./policies   # to be modified and added accordingly if policy is not on the same folder as test
${POLICY_NAME}           NS-squid-haproxy-Elasticity-Policy-Premium.json    # The policy to be uploaded and tested


*** Test Cases ***
Setting the SP Path
    Set SP Path     ${HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
Upload the Package
    ${result} =     Upload Package      ${FILE_SOURCE_DIR}/${FILE_NAME}
    Should Be True     ${result[0]}
    Set Suite Variable     ${PACKAGE_UUID}  ${result[1]}
    Log     ${PACKAGE_UUID}
    ${service} =     Map Package On Service  ${result[1]}
    Should Be True     ${service[0]}
    Set Suite Variable     ${SERVICE_UUID}  ${service[1]}
    Log     ${SERVICE_UUID}
Create Runtime Policy
###Create Runtime code will go here once ready
Define Runtime Policy as default
###Define Runtime Policy as default code will go here once ready
Check monitoring rules
###Check monitoring rules code will go here once ready
Deactivate Runtime Policy
###Deactivate Runtime Policy code will go here once ready
Re-activate Runtime Policy
###Re-activate Runtime Policy code will go here once ready
Terminate Service
###Terminate Service code will go here once ready
Remove the Package
    ${result} =     Remove Package      ${PACKAGE_UUID}
    Should Be True     ${result[0]}
