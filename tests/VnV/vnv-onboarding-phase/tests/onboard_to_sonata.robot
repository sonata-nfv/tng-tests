*** Settings ***
Resource    environment/variables.txt
Resource    VnvGKOperationKeywords.robot 
Resource    VnvOsmOperationKeywords.robot
Resource    VnvPlannerOperationKeywords.robot 
Library    OperatingSystem

*** Test Cases ***
testcase1   
    Delete All Packages From Sonata
    #Delete All Test Plans From Vnv
    Do Get Existing Packages  
    Check HTTP Response Status Code Is    200
    Response Should Be X Than   =    0
    Do Get Existing Plans  
    Check HTTP Response Status Code Is    200
    Response Should Be X Than   =    0  
testcase2   
    Do Upload A Package To Sonata       ${CURDIR}/${INDUSTRIAL_PILOT_NS}
    Do Upload A Package To Sonata       ${CURDIR}/${INDUSTRIAL_PILOT_T}
    Check Correspondance Between Test And Service 
testcase3
    Do Get Existing Packages
    Check HTTP Response Status Code Is    200
    Response Should Be X Than   >    1   
    Do Get Existing Plans  
    Check HTTP Response Status Code Is    200
    Response Should Be X Than   >    1  
testcase4
    Do Upload A Package To Sonata       ${CURDIR}/${MOBIUS_NS}   
    Upload A TGO To Osm     