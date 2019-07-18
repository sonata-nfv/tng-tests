*** Settings ***
Documentation     Test suite template for deploy and undeploy
Library           tnglib
Library           Collections
Library           Process
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
${SP_HOST}     http://qual-sp-bcn.5gtango.eu
${READY}       READY
${PASSED}      PASSED
${MTC_NAME}	   up

*** Test Cases ***
Setting the SP Path
    Set SP Path     ${SP_HOST}
    ${result} =    Sp Health Check
    Should Be True   ${result}



GET monitoring Targets
	@{TARGETS} =  Get Prometheus Targets
	Set Global Variable    @{TARGETS}

CHECK targets Status from Monitoring Framework
    @{TRGS_STATUS} =  Get Metric    ${MTC_NAME}

	FOR     ${TARGET}  IN  @{TARGETS[1]}
		Find Record  ${TARGET}   @{TRGS_STATUS} 
		#Should Contain    ${resp.stdout}    success
		Log    ${TARGET}
    END

*** Keywords ***
Find Record
    [Arguments]  ${TARGET}    @{TRGS_STATUS} 
    FOR     ${TRG}  IN  @{TRGS_STATUS[1]}
        Run Keyword If    '${TRG['instance']}'== '${TARGET['endpoint']}'   Should Contain  ${TRG['value']}    1 
    END

