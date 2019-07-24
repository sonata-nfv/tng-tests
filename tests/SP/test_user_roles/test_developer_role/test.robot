*** Settings ***
Documentation   Test the User Management Admin Role
Library         tnglib
Library         Collections
Library         DateTime
Library         json

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

Register a new user with developer role
    # if user is admin continue to creation of admin user
    Register User

Check if token exists
    ${token}=      Get Token
    Run keyword If 	${token[0]} == True 	Check Valid Token
    Run keyword If 	${token[0]} == False 	Login

Obtain Packages
    ${packages}=      Get Packages
    Should be True      ${packages[0]}
    # Not executed yet - need to implement first the permission feature
    # tng-gtk-usr/endpoints/:username

Obtain Services
    ${services}=     get Service Descriptors
    Should be True      ${services[0]}
    # Not executed yet - need to implement first the permission feature
    # tng-gtk-usr/endpoints/:username

Obtain SLA Templates
    ${templates}=      get Sla Templates
    Should be True      ${templates[0]}
    # Not executed yet - need to implement first the permission feature
    # tng-gtk-usr/endpoints/:username

Obtain SLA Agreements
    ${agreements}=      Get Agreements      nsi_uuid=None
    Should be True      ${agreements[0]}
    # Not executed yet - need to implement first the permission feature
    # tng-gtk-usr/endpoints/:username

Obtain Policies
    ${policies}=      Get Policies
    Should be True      ${policies[0]}
    # Not executed yet - need to implement first the permission feature
    # tng-gtk-usr/endpoints/:username

Logout User
    ${result}=      Logout User      token=${valid_token[1]}
    Should be True      ${result[0]}

Delete user
    ${result}=      Delete User   username=${username}
    Should be True      ${result[0]}


Obtain GrayLogs
    ${to_date} =  Get Current Date
    Set Suite Variable  ${param_file}   True
    Get Logs  ${from_date}  ${to_date}  ${SP_HOST}  ${param_file}

*** Keywords ***
Check Status
    ${status} =     Get Request     ${REQUEST}
    Should Be Equal    ${READY}  ${status[1]['status']}

Register User
    ${result} =      Register         username=tango_dev_test   password=dev_test   name=tango_dev_test   email=tango@dev.com   role=developer
    ${json_resp} = 	Set Variable	${result[1]}
    ${username}=    Get From Dictionary    ${json_resp}    username
    Set Suite Variable     ${username}
	Set Global Variable  ${username}
    Should Be True  ${result[0]}

Check Valid Token
    ${valid_token}=    Is Token Valid
    # if token is still valid pass it to the headers
    if ${valid_token[0]} == True
        # pass token into headers
        add token to header(${valid_token[1]})
        Set Suite Variable     ${valid_token[1]}
        Set Global Variable  ${valid_token[1]}
        Should Be True  ${valid_token[0]}
    # if token is not still valid attempt a new login
    else:
        Login

Login
    ${valid_token}=      Update Token      username=tango_dev_test   password=dev_test
    Should Be True  ${valid_token[0]}
    Set Suite Variable     ${valid_token[1]}
    Set Global Variable  ${valid_token[1]}
    Should Be True  ${valid_token[0]}

