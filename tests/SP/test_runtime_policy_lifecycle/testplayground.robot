*** Settings ***
Documentation     Test suite for enforcing a Runtime Policy to the SP platform
Library           tnglib

*** Variables ***
${HOST}                http://pre-int-sp-ath.5gtango.eu   #  the name of SP we want to use
${FILE_SOURCE_DIR}     ./packages   # to be modified and added accordingly if package is not on the same folder as test
${FILE_NAME}           eu.5gtango.ns-squid-haproxy.0.1.tgo    # The package to be uploaded and tested
${POLICIES_SOURCE_DIR}     ./policies   # to be modified and added accordingly if policy is not on the same folder as test
${POLICY_NAME}           NS-squid-haproxy-Elasticity-Policy-Premium.json    # The policy to be uploaded and tested
${POLICY_UUID}         1e48d0ae-2071-412b-8bc5-b306c06bf936
${SERVICE_UUID}        ca11aad6-6bc2-4ba5-aa51-7b25995b66aa

*** Test Cases ***
Setting the SP Path
    Set SP Path     ${HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
#Upload the Package
#    ${result} =     Upload Package      ${FILE_SOURCE_DIR}/${FILE_NAME}
#    Should Be True     ${result[0]}
#    Set Suite Variable     ${PACKAGE_UUID}  ${result[1]}
#    Log     ${PACKAGE_UUID}
#Create Runtime Policy
#    ${result} =     Create Policy      ${POLICIES_SOURCE_DIR}/${POLICY_NAME}
#    Should Be True     ${result[0]}
#    Set Suite Variable     ${POLICY_UUID}  ${result[1]}
#Remove the Package
#    ${result} =     Remove Package      ${PACKAGE_UUID}
#    Should Be True     ${result[0]}
#Define Runtime Policy as Default
#    ${result} =     Define Policy As Default      ${POLICY_UUID}   service_uuid=${SERVICE_UUID}
#    Should Be True     ${result[0]}
