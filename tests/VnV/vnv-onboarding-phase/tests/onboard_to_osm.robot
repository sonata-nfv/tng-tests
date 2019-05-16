*** Settings ***
Resource    environment/variables.txt
Resource    VnvOsmOperationKeywords.robot 
Library    OperatingSystem

*** Test Cases ***
testcase1 
    Get Token 
    Do Get Existing Packages
    Do Upload A Ns To Osm      ${CURDIR}/descriptors/osm/moebius-ns.yml
    Do Upload A VNF To Osm        ${CURDIR}/descriptors/osm/moebius.yml
    Do Get Existing Packages
        
       