*** Settings ***
Documentation     Test suite for scaling-out and scaling-in an VNF 
Library           tnglib

*** Variables ***
${HOST}                http://qual-sp-bcn.5gtango.eu   #  the name of SP we want to use
${READY}       READY
#${FILE_SOURCE_DIR}     ../../../packages   # to be modified and added accordingly if package is not on the same folder as test
${FILE_SOURCE_DIR}     ../../../../Escritorio/cirros
#${FILE_NAME}           eu.5gtango.test-ns-nsid1v.0.1.tgo    # The package to be uploaded and tested
${FILE_NAME}           basic_package.tgo 
${NS_PACKAGE_SHORT_NAME}  5gtango-project-sample
${TST_PACKAGE_SHORT_NAME}  5gtango-project-sample
${FUNCTION_NAME}    default-vnf0

*** Test Cases ***
Setting the SP Path
    Set SP Path     ${HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
Clean the Packages
    @{PACKAGES} =   Get Packages
    FOR     ${PACKAGE}  IN  @{PACKAGES[1]}
        Run Keyword If     '${PACKAGE['name']}'== '${NS_PACKAGE_SHORT_NAME}' or '${PACKAGE['name']}'== '${TST_PACKAGE_SHORT_NAME}'     Remove Package      ${PACKAGE['package_uuid']}
    END    
Upload the Package
    ${result} =     Upload Package      ${FILE_SOURCE_DIR}/${FILE_NAME}
    Should Be True     ${result[0]}
    ${service} =     Map Package On Service      ${result[1]}
    Should Be True     ${service[0]}
    Set Suite Variable     ${SERVICE_UUID}  ${service[1]}
    Log     ${SERVICE_UUID}
Get function descriptor
    @{FUNCTIONS} =   get_function_descriptors
    Log     ${FUNCTIONS}
    FOR     ${FUNCTION}  IN  @{FUNCTIONS[1]}
        Run Keyword If     '${FUNCTION['name']}'== '${FUNCTION_NAME}'   Set Suite Variable     ${FUNCTION_UUID}     ${FUNCTION['descriptor_uuid']} 
    END  
    Log     ${FUNCTION_UUID}

#Get Requests test
    #${rr} =     Get Requests
    #Log     ${rr}

Scaling Out
    Set Suite Variable     ${SERVICE_UUID}  2c5b030e-854c-4c87-a6cb-e35af844af5b
    Log     ${SERVICE_UUID}
    ${SCALE_OUT} =  service_scale_out    ${SERVICE_UUID}     ${FUNCTION_UUID}
    Log     ${SCALE_OUT}
    Set Suite Variable     ${REQUEST}  ${SCALE_OUT[1]}
    Log     ${REQUEST}    
#Deploying Service
    #${init} =   Service Instantiate     ${SERVICE_UUID}
    #Log     ${init}
    #Set Suite Variable     ${REQUEST}  ${init[1]}
    #Log     ${REQUEST}
Wait For Ready
    Wait until Keyword Succeeds     3 min   5 sec   Check Status
    Set SIU

Scaling In
    Set Suite Variable     ${SERVICE_UUID}  2c5b030e-854c-4c87-a6cb-e35af844af5b
    Log     ${SERVICE_UUID}
    ${SCALE_OUT} =  service_scale_in    ${SERVICE_UUID}     ${FUNCTION_UUID}
    Log     ${SCALE_OUT}
    Set Suite Variable     ${REQUEST}  ${SCALE_OUT[1]}
    Log     ${REQUEST}  

Terminate Service
    ${ter} =    Service Terminate   ${TERMINATE}
    Log     ${ter}
    Set Suite Variable     ${TERM_REQ}  ${ter[1]}
    Wait until Keyword Succeeds     2 min   5 sec   Check Terminate

#Clean the Packages
#    Remove all Packages

#Clean the Packages
#    @{PACKAGES} =   Get Packages
#    FOR     ${PACKAGE}  IN  @{PACKAGES[1]}
#        Run Keyword If     '${PACKAGE['name']}'== '${NS_PACKAGE_SHORT_NAME}' or '${PACKAGE['name']}'== '${TST_PACKAGE_SHORT_NAME}'     Remove Package      ${PACKAGE['package_uuid']}
#    END


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
