*** Settings ***
Resource    environment/variables.txt
Resource    VnvGKOperationKeywords.robot 
Resource    VnvPlannerOperationKeywords.robot 
Library    OperatingSystem

*** Test Cases ***
testcase1
    Do Get Existing Packages
    Check HTTP Response Status Code Is    200
    Response Should Be X Than   >    1    
testcase2   
    Delete All Packages From Sonata
    Delete All Test Plans From Vnv
testcase3   
    #Do Get Existing Packages
    #Check HTTP Response Status Code Is    200
    #Response Should Be X Than   =     0    
    Do Upload A Package To Sonata       packages/eu.5gtango.media-performance-test.0.1.tgo
    Do Upload A Package To Sonata        packages/eu.5gtango.ns-mediapilot-service-k8s.0.3.tgo
    Check Correspondance Between Test And Service
    #Check Test Plan Created
    
       