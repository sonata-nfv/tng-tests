*** Settings ***
Resource    environment/variables.txt
Resource    VnvOsmOperationKeywords.robot 
Library    OperatingSystem

*** Test Cases ***
testcase1 
    Get Token 
    Do Upload A Ns To Osm      packages/eu.5gtango.media-performance-test.0.1.tgo
    Do Upload A VNF To Osm        packages/eu.5gtango.ns-mediapilot-service-k8s.0.3.tgo
    #Check Test Plan Created
    
       