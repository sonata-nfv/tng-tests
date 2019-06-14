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
    
    Do Upload A VNF To Osm        ${CURDIR}/descriptors/osm/mobius_vnfd.yaml
    #Response Status Code Should Equal   201
    Do Upload A VNF To Osm        ${CURDIR}/descriptors/osm/mosquitto_vnfd.yaml
    #Response Status Code Should Equal   201
    Do Upload A VNF To Osm        ${CURDIR}/descriptors/osm/mysql_vnfd.yaml
    #Response Status Code Should Equal   201
    Do Upload A Ns To Osm      ${CURDIR}/descriptors/osm/iot_mobius_nsd.yaml
    #Response Status Code Should Equal   201
    #Check HTTP Response Status Code Is    200
testcase3
    Do Upload A Package To Sonata       ${CURDIR}/${MOBIUS_NS}   
    Do Upload A TGO To Osm     