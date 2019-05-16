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
    Set Headers    {"Content-type" : "application/octet-stream", "Accept" : "application/octet-stream", "Authorization" : "${bearer}" } 
    ${ns}=     Get Binary File       ${packageName}
    ${resp}=    Post    ${OSM}:9999/osm/vnfpkgm/v1/ns_descriptors_content  data=${ns}   
    log to console       \nOriginal JSON:\n${resp}

Do Upload A VNF To Osm
    [Arguments]    ${packageName}
    log    Uploading a package to OSM
    Set Headers    {"Content-type" : "application/octet-stream", "Accept" : "application/octet-stream", "Authorization" : "${bearer}" } 
    ${vnf}=    Get Binary File        ${packageName}
    ${resp}=    Post     ${OSM}:9999/osm/vnfpkgm/v1/vnf_packages_content  data=${vnf}      
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