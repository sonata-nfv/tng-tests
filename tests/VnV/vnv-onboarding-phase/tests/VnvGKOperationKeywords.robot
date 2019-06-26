*** Settings ***
Library    utility.py
Resource    environment/variables.txt
Library    REST    
Library    JsonValidator
Library    OperatingSystem
Library    Collections
Library         tnglib     
#Suite Teardown    Terminate All Processes    kill=true

Library    Process

*** Keywords ***
Do Get Existing Packages
    log    Trying to get existing packages on SONATA
    Set Headers    {"Accept":"${ACCEPT}"}  
    Get  ${GK_ENDPOINT}/packages
    ${outputResponse}=    Output    response 
    log      \nexisting pkgs response:\n ${outputResponse}
    Set Global Variable    @{response}    ${outputResponse}

Check HTTP Response Status Code Is
    [Arguments]    ${expected_status}
    Log    Validate Status code    
    Should Be Equal as strings   ${response[0]['status']}    ${expected_status}
    log to console       \nresponse status check:\n${response[0]['status']}
Response Should Be X Than  
    [Arguments]   ${x}  ${num1}          
    Log    Validate resp length
    Should Be X Than   ${response[0]['body']}    ${x}   ${num1} 

Do Upload A Package To Sonata
    [Arguments]    ${packageName}
    log    Uploading a package to SONATA: ${packageName}
    ${resp}=  Upload File       ${packageName}     ${GK_ENDPOINT}/packages 
    log to console       \nUpload response:\n${resp}

Check Correspondance Between Test And Service
    log     Find correspondance between test and services uploaded in SONATA
    ${outputResponseTests}=     Get     ${GK_ENDPOINT}/tests/descriptors/ 
    ${outputResponseServices}=     Get     ${GK_ENDPOINT}/services/ 
    Has Match      ${outputResponseTests['body']}      ${outputResponseServices['body']}
Delete All Packages From Sonata
    Do Get Existing Packages
    log to console     Delete all packages
    Set SP Path     ${SP}
     :FOR    ${item}    IN    @{response[0]['body']}
     \    ${egm_pkg}=  Evaluate   "egm" in """${item['pd']['name']}"""
     \    Run Keyword If    '${egm_pkg}' == 'True'     Delete Pkg    ${item} 
    Sleep     10s
    Do Get Existing Packages
    Response Should Be X Than    =   0
    
Delete Pkg
     [Arguments]    ${item}
     log to console       \nDELETING from SONATA:\n${item['uuid']}-${item['pd']['name']}
     Remove Package          ${item['uuid']}
     ${resp}=    Delete  ${GK_ENDPOINT}/packages/${item['uuid']}
     log to console       \nResp deleting pkg:\n${resp}

