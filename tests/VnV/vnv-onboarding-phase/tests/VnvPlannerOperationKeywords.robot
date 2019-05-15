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
    log to console       \nOriginal JSON:\n${outputResponse}   
     
Delete All Test Plans From Vnv
     ${resp}=    Get     ${PLANNER_ENDPOINT}/test-plans
     log to console       \nDelete test plan response:\n${resp}
     :FOR    ${uuid}    IN    @{resp[0]['body']}
    \    log to console       \nTEST PLAN UUID:\n${uuid}
    \    Delete Test Plan   ${uuid} 
     log to console       \nOriginal JSON:\n${resp}
            
Delete Test Plan 
    [Arguments]    ${uuid}
    log     delete test Plan
    ${resp}=    Delete  ${PLANNER_ENDPOINT}/test-plans/${uuid}
    log to console       \nOriginal JSON:\n${resp}           