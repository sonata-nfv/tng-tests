*** Settings ***
Library    utility.py
Resource    environment/variables.txt
Library    REST     ssl_verify=false
Library    JsonValidator
Library    OperatingSystem
Library    Collections
Library    tnglib 
Library    json 
Library    yaml   

Library    Process

*** Keywords ***
Do Get Existing Packages
    log    Trying to get existing packages on OSM
    Set Headers    {"Content-Type": "application/json", "Accept":"application/json", "Authorization": "${bearer}" } 
    Get  ${OSM}:9999/osm/vnfpkgm/v1/vnf_packages

Do Upload A Ns To Osm
    [Arguments]    ${packageName}
    log    Uploading a package to OSM  
    #Set Headers    {"Content-type" : "application/yaml", "Accept" : "application/yaml", "Authorization" : "${bearer}" } 
    ${ns}=     Get File       ${packageName}
    ${resp}=     Upload Descriptor To Osm      ${OSM}:9999/osm/nsd/v1/ns_descriptors_content  ${ns}      ${bearer}
    log to console       \nOriginal JSON:\n${resp}

Do Upload A VNF To Osm
    [Arguments]    ${packageName}
    log    Uploading a package to OSM
    #Set Headers    {"Content-type" : "application/yaml", "Accept" : "application/yaml", "Authorization" : "${bearer}" } 
    ${vnf}=    Get File        ${packageName}
    ${resp}=    Upload Descriptor To Osm     ${OSM}:9999/osm/vnfpkgm/v1/vnf_packages_content  ${vnf}      ${bearer}
    log to console       \nOriginal JSON:\n${resp}
    
Get Token
    log    Uploading a package to OSM
    Set Headers    {"Accept":"application/json"}
    ${data}=     Create Dictionary      username=${OSM_USER}    password=${OSM_PASSWORD}       project_id=${OSM_PROJECT_ID} 
    ${string_json}=     json.Dumps      ${data}
    log to console   ${string_json}
    ${result}=    Auth To Osm    ${string_json}     ${OSM}:9999/osm/admin/v1/tokens 
    log to console       \nResp:\n${result}
    ${bearer} =   Catenate    Bearer     ${result['id']}
    log to console       \nBearer:\n${bearer}
    Set Global Variable    ${bearer}