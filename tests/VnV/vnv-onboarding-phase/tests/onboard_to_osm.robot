*** Settings ***
Resource    environment/variables.txt
Resource    VnvOsmOperationKeywords.robot 
Library    OperatingSystem

*** Test Cases ***
testcase1 
    Get Token 
    Do Upload A Ns To Osm      descriptors/moebius-ns.yml
    Do Upload A VNF To Osm        descriptors/moebius.yml
        
       