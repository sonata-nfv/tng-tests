*** Settings ***
Documentation     Test suite template for deploy and undeploy
Library           tnglib
Library           Collections
Library           Process
Suite Teardown    Terminate All Processes    kill=True

*** Variables ***
${SP_HOST}      http://qual-sp-bcn.5gtango.eu
${READY}       READY
${PASSED}      PASSED
${SRV_UUID}	   4e3895ed-2d30-430f-9210-bcfe8cc467cb
@{TARGETS}

*** Test Cases ***
Setting the SP Path
    Set SP Path     ${SP_HOST}
    ${result} =    Sp Health Check
    Should Be True   ${result}

GET the Packages
    @{PACKAGES} =   Get Packages	
	FOR     ${PACKAGE}  IN  @{PACKAGES[1]}
        Log     ${PACKAGE['package_uuid']}
    END

GET monitoting Targets
	@{TARGETS} =  Get Prometheus Targets
	FOR     ${TARGET}  IN  @{TARGETS[1]}
        Log     ${TARGET}
        ${resp} =  Run Process    curl -i http://10.200.16.2:30090/merics 		shell=True    cwd=/usr/bin
#		${resp} =  Run Process 		curl -i -g "http://pre-int-vnv-bcn.5gtango.eu:9090/api/v1/series?match[]={job='pushgateway'}" 	shell=True		cwd=/usr/bin
		Log     ${resp}
		Should Contain    ${resp.stdout}    success
    END

