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
    Do Upload A Ns To Osm      ${CURDIR}/descriptors/osm/moebius-ns.yml
    #Check HTTP Response Status Code Is    200
    Response Status Code Should Equal   201
    Do Upload A VNF To Osm        ${CURDIR}/descriptors/osm/moebius.yml
    Response Status Code Should Equal   201
    #Check HTTP Response Status Code Is    200
   