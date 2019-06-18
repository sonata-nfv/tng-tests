*** Settings ***
Resource    environment/variables.txt
Resource    VnvOsmOperationKeywords.robot 
Resource    VnvGKOperationKeywords.robot 
Library    OperatingSystem

*** Test Cases ***
testcase1  
    Get Token      
    Do Delete All NS
    Do Get Existing NSs
    Response Should Be X Than   =    0
    Do Delete All VNF
    Do Get Existing VNFs
    Response Should Be X Than   =    0
testcase2 
    Get Token 
    
    #Check HTTP Response Status Code Is    200
    
    Do Upload A VNF To Osm        ${DESCRIPTORS}/${MOBIUS_NSD}
    #Response Status Code Should Equal   201
    Do Upload A VNF To Osm        ${DESCRIPTORS}/${MOBIUS_VNF_MOSQUITTO}
    #Response Status Code Should Equal   201
    Do Upload A VNF To Osm        ${DESCRIPTORS}/${MOBIUS_VNF_MYSQL}
    #Response Status Code Should Equal   201
    Do Upload A Ns To Osm      ${DESCRIPTORS}/${MOBIUS_VNF_MOBIUS}
    #Response Status Code Should Equal   201
    #Check HTTP Response Status Code Is    200
   