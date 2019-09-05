*** Settings ***
Documentation   Test the SLAs E2E test
Library         tnglib
Library         Collections
Library         DateTime

*** Variables ***
${SP_HOST}                http://pre-int-sp-ath.5gtango.eu  #  the name of SP we want to use
${READY}       READY
${FILE_SOURCE_DIR}     ./packages   # to be modified and added accordingly if package is not on the same folder as test
${NS_PACKAGE_NAME}           eu.5gtango.test-ns-nsid1c.0.1.tgo    # The package to be uploaded and tested

*** Test Cases ***
Setting the SP Path
	#From date to obtain GrayLogs
    ${from_date} =   Get Current Date
    Set Global Variable  ${from_date}
	
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True  ${result}

Clean all packages
    Remove All Packages

Upload the Package
    ${result} =     Upload Package      ${FILE_SOURCE_DIR}/${NS_PACKAGE_NAME}
    Should Be True     ${result[0]}
	Set Suite Variable     ${PACKAGE_UUID}  ${result[1]}
    ${service} =     Map Package On Service      ${result[1]}
    Should Be True     ${service[0]}
    Set Suite Variable     ${SERVICE_UUID}  ${service[1]}
    Log     ${SERVICE_UUID}

Generate the SLA Template
    ${result}=      Create Sla Template         templateName=int_test_3   nsd_uuid=${SERVICE_UUID}   expireDate=20/12/2030   guaranteeId=g1   provider_name=UPRC   dflavour_name=    template_initiator=admin    provider_name=admin   service_licence_type=private   allowed_service_instances=5    service_licence_expiration_date=20/12/2030
    Set Suite Variable     ${SLA_UUID}   ${result[1]}
    Should be True      ${result[0]}

Deploying Service
    ${init} =   Service Instantiate     ${SERVICE_UUID}   ${SLA_UUID}
    Log     ${init}
    Set Suite Variable     ${REQUEST}  ${init[1]}
    Log     ${REQUEST}
Wait For Ready
    Wait until Keyword Succeeds     3 min   5 sec   Check Status
    Set SIU

Get Agreements
    ${result}=      Get Agreements      nsi_uuid=${TERMINATE}
    Should be True      ${result[0]}

Terminate Service
    ${ter} =    Service Terminate   ${TERMINATE}
    Log     ${ter}
    Set Suite Variable     ${TERM_REQ}  ${ter[1]}
    Wait until Keyword Succeeds     2 min   5 sec   Check Terminate

Delete SLA
    ${result}=      Delete SlaTemplate    ${SLA_UUID}
    Should be True      ${result[0]}
	
Delete Package
	${result}=   Remove Package    package_uuid=${PACKAGE_UUID}

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
