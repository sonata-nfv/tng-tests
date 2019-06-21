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
    Do Upload A VNF To Osm        ${CURDIR}/NSIMOB_OSM/mobius_vnfd.yaml
    Do Upload A VNF To Osm        ${CURDIR}/NSIMOB_OSM/mosquitto_vnfd.yaml
    Do Upload A VNF To Osm        ${CURDIR}/NSIMOB_OSM/mysql_vnfd.yaml
    Do Upload A Ns To Osm      ${CURDIR}/NSIMOB_OSM/iot_mobius_nsd.yaml
    #Response Status Code Should Equal   201
testcase3
    Get Token 
    Do Upload A Package To Osm        ${CURDIR}/NSIMOB_OSM/build/mobius_vnfd.tar.gz
    Do Upload A Package To Osm        ${CURDIR}/NSIMOB_OSM/build/mosquitto_vnfd.tar.gz
    Do Upload A Package To Osm        ${CURDIR}/NSIMOB_OSM/build/mysql_vnfd.tar.gz
    Do Upload A Package To Osm      ${CURDIR}/NSIMOB_OSM/build/iot_mobius_nsd.tar.gz
