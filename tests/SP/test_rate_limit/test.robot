*** Settings ***
Documentation   Test the SLAs E2E test
Library         tnglib
Library         Collections
Library         DateTime

*** Variables ***
${SP_HOST}                http://pre-int-sp-ath.5gtango.eu  #  the name of SP we want to use
${READY}       READY

*** Test Cases ***
Setting the SP Path
	#From date to obtain GrayLogs
    ${from_date} =   Get Current Date
    Set Global Variable  ${from_date}
	
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True  ${result}

For-Loop-In-Range
	: FOR    ${INDEX}    IN RANGE    1    15
		Run Keyword IF 	${INDEX} != 11   Make Request 
						else   Make Request Not Ok
	END

Obtain GrayLogs
    ${to_date} =  Get Current Date
    Set Suite Variable  ${param_file}   True
    Get Logs  ${from_date}  ${to_date}  ${SP_HOST}  ${param_file}
	
*** Keywords ***
Make Request
    ${result}=      Get Agreements 
	$(status_code) = convert to string ${result.status_code}
	should be equal $(status_code) 200

Make Request Not Ok
    ${result}=      Get Agreements 
	$(status_code) = convert to string ${result.status_code}
	should be not equal $(status_code) 200