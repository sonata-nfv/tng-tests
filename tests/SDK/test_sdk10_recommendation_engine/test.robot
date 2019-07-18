*** Settings ***
Documentation   Test the Recommendation Engine Integration with the GTK
Library         tnglib
Library         Collections
Library         DateTime
Library         json

*** Variables ***
${SP_HOST}     http://pre-int-vnv-bcn.5gtango.eu
${FILE_SOURCE_DIR}     ./packages   
${NS_PACKAGE_NAME}           eu.5gtango.media-performance-test.0.1.tgo 
${user_name}		int_test_user5   

*** Test Cases ***
Setting the SP Path
	#From date to obtain GrayLogs
    ${from_date} =   Get Current Date
    Set Global Variable  ${from_date}
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True  ${result}

Create a User
    ${result} =      Register         username=int_test_user5   password=tango_cust   name=tango   email=tango@tango.com   role=admin
	${json_resp} = 	Set Variable	${result[1]}
	${username}=    Get From Dictionary    ${json_resp}    username
	Set Global Variable  ${username}
    Should Be True  ${result[0]}

Login User
	${result} = 	Update Token 	  username=int_test_user5     password=tango_cust
	${token} = 	Set Variable	${result[1]}
	Set Global Variable  ${token}
	Should Be True  ${result[0]}

Add Token to Header
	${result} = 	Add Token To Header	  token=${token}
	${result2} =     Sp Health Check
    Should Be True  ${result2} 
	
Upload the Package
    ${result} =     Upload Package      ${FILE_SOURCE_DIR}/${NS_PACKAGE_NAME}
    Should Be True     ${result[0]}
	Set Suite Variable     ${PACKAGE_UUID}  ${result[1]}
	Set Global Variable  ${PACKAGE_UUID}

Retrieve user from DSM
	${result} =     Get Users
	${users} = 		Set Variable    ${result[1]}
	Run Keyword If  "int_test_user" in ${users}  Log  Pass
	
Delete the User
	${result} =     Delete User      ${username}
	Should Be True     ${result[0]}

Delete the Rec User
	${result} =     Delete Rec User      ${username}
	Should Be True     ${result[0]}
	
Delete Package
	${result}=   Remove Package    package_uuid=${PACKAGE_UUID}
	
Obtain GrayLogs
    ${to_date} =  Get Current Date
    Set Suite Variable  ${param_file}   True
    Get Logs  ${from_date}  ${to_date}  ${SP_HOST}  ${param_file}