*** Settings ***
Documentation   Test the rate limit mechanism by the GTK
Library         tnglib
Library 		RequestsLibrary
Library         Collections
Library         DateTime

*** Variables ***
${SP_HOST}                http://pre-int-sp-ath.5gtango.eu  #  the name of SP we want to use
${READY}       READY
${COUNTER} =	${0}


*** Test Cases ***
Setting the SP Path
	#From date to obtain GrayLogs
    ${from_date} =   Get Current Date
    Set Global Variable  ${from_date}
	
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True  ${result}

For-Loop-In-Range
	LOG 	${COUNTER}
	: FOR    ${INDEX}   IN RANGE    1 	15
		Make Request
	END
	should be equal 	${COUNTER} 	${10}

Obtain GrayLogs
    ${to_date} =  Get Current Date
    Set Suite Variable  ${param_file}   True
    Get Logs  ${from_date}  ${to_date}  ${SP_HOST}  ${param_file}
	
*** Keywords ***
Make Request
	create session 	FetchData	${SP_HOST}
	${result} = 	RequestsLibrary.Get Request 	FetchData 	:32002/api/v3/requests
	${status} = 	Convert to String 	${result.status_code}
	Run keyword If 	${status} == 200 	Increment Counter

Increment Counter
	${count} = 	Evaluate 	${COUNTER} + 1
	Set test variable 	${COUNTER} 	${count}


Make Request Not Ok
	create session	FetchData	${SP_HOST}
	${result} = 	RequestsLibrary.Get Request 	FetchData 	:32002/api/v3/requests
	${status} = 	Convert to String 	${result.status_code}
	should not be equal 	${status} 	200
