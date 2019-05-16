*** Settings ***
Library    utility.py
Resource    environment/variables.txt
Library    REST    
Library    JsonValidator
Library    OperatingSystem
Library    Collections
Library         tnglib 
Library     json    
#Suite Teardown    Terminate All Processes    kill=true

Library    Process

*** Keywords ***
Do Get Existing Packages
    log    Trying to get existing packages on OSM
    Set Headers    {"Content-Type": "application/yaml", "Authorization": ${token} } 
    Get  ${OSM}:9999/osm/vnfpkgm/v1/vnf_packages
    ${outputResponse}=    Output    response 
    Set Global Variable    @{response}    ${outputResponse}


Do Upload A Ns To Osm
    [Arguments]    ${packageName}
    log    Uploading a package to OSM
    Set Headers    {"Content-Type": "application/yaml", "Authorization": ${token} } 
    ${ns}= | Get file |     ${packageName}
    ${resp}=  Post    ${OSM}:9999/osm/vnfpkgm/v1/ns_descriptors_content   data={ns}
    log to console       \nOriginal JSON:\n${resp}

Do Upload A VNF To Osm
    [Arguments]    ${packageName}
    log    Uploading a package to OSM
    Set Headers    {"Content-Type": "application/yaml", "Authorization": ${token} }
    ${vnf}= | Get file |     ${packageName}
    ${resp}=  Post     ${OSM}:9999/osm/vnfpkgm/v1/vnf_packages_content  data={vnf}
    log to console       \nOriginal JSON:\n${resp}
    
Get Token
    log    Uploading a package to OSM
    Set Headers    {"Content-Type": "application/json"}
    ${data}=     Create Dictionary      username=${OSM_USER} password=${OSM_PASSWORD} project_id=${OSM_PROJECT_ID} 
    ${string_json}=     json.Dumps      ${data}
    ${resp}=  Post      ${OSM}:9999/osm/admin/v1/tokens     data={string_json} 
    log to console       \nToken:\n${resp}
    Set Global Variable    @{token}    Catenate    Bearer ${resp}