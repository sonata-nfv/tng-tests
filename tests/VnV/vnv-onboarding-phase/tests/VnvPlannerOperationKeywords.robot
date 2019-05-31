*** Settings ***
Resource    environment/variables.txt
Library    REST   
Library    OperatingSystem
#Suite Teardown    Terminate All Processes    kill=true
Library    Process

*** Keywords ***
Do Get Existing Plans
    log    Trying to get existing plans from VNV
    Set Headers    {"Accept":"${ACCEPT}"}  
    Get  ${PLANNER_ENDPOINT}/test-plans
    ${outputResponse}=    Output    response 
    Set Global Variable    @{response}    ${outputResponse}
    log to console       \ntest plans:\n${outputResponse}   
     
Delete All Test Plans From Vnv
     ${resp}=    Get     ${PLANNER_ENDPOINT}/test-plans
     log to console       \nDelete test plan response:\n${resp}
     :FOR    ${item}    IN    @{resp['body']}
     \    log to console       \nDELETING TEST PLAN UUID:\n${item['uuid']}
     \    Delete Test Plan   ${item['uuid']}
     Sleep     10s
            
Delete Test Plan 
    [Arguments]    ${uuid}
    log     delete test Plan
    ${resp}=    Delete  ${PLANNER_ENDPOINT}/test-plans/${uuid}
    log to console       \ndelete testplan response:\n${resp}           