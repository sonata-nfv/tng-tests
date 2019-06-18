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
Do Get Existing VNFs
    log    Trying to get existing vnfs on OSM
    Set Headers    {"Content-Type": "application/json", "Accept":"application/json", "Authorization": "${bearer}" } 
    ${resp}=     Get  ${OSM}:9999/osm/vnfpkgm/v1/vnf_packages
    #log to console       \nexisting VNFs:\n${resp}
    Set Global Variable    @{response}    ${resp}
Do Get Existing NSs
    log    Trying to get existing ns on OSM
    Set Headers    {"Content-Type": "application/json", "Accept":"application/json", "Authorization": "${bearer}" } 
    ${resp}=     Get  ${OSM}:9999/osm/nsd/v1/ns_descriptors_content
    #log to console       \nexisting NSs:\n${resp}
    Set Global Variable    @{response}    ${resp}
    
Do Delete All NS
     Do Get Existing NSs
     ${nss}=   Output    response
    :FOR    ${item}    IN    @{nss['body']}
    \    log to console       \nDELETING NS id:\n${item['id']}
    \    Do Delete NS   ${item['id']}    
Do Delete All VNF
     Do Get Existing VNFs
     ${vnfs}=      Output    response 
    :FOR    ${item}    IN    @{vnfs['body']}
    \    log to console       \nDELETING VNFS id:\n${item['id']}
    \    Do Delete NS   ${item['id']}    
    
Do Delete NS
    [Arguments]    ${ns}
    log    Trying to delete existing NS on OSM
    Set Headers    {"Content-Type": "application/json", "Accept":"application/json", "Authorization": "${bearer}" } 
    ${resp}=   Delete  ${OSM}:9999/osm/nsd/v1/ns_descriptors/${ns}
    log to console       \ndeleting NS:\n${resp}
Do Delete VNF
    [Arguments]    ${vnf}
    log    Trying to delete existing VNF on OSM
    Set Headers    {"Content-Type": "application/json", "Accept":"application/json", "Authorization": "${bearer}" } 
    ${resp}=    Delete  ${OSM}:9999/osm/vnfpkgm/v1/vnf_packages_content/${vnf}
    log to console       \ndeleting NS:\n${resp}
Do Upload A Ns To Osm
    [Arguments]    ${packageName}
    log    Uploading a package to OSM  
    Set Headers    {"Content-Type": "application/json", "Authorization" : "${bearer}"}  # "Content-type" : "application/yaml",  "Accept" : "application/yaml",
    ${yaml}=    Get Binary File    ${packageName}
    ${body}=   Yaml To Json    ${yaml}
    ${resp}=     POST     ${OSM}:9999/osm/nsd/v1/ns_descriptors_content  ${body}   
    log to console       \nOriginal JSON:\n${resp}

Do Upload A VNF To Osm
    [Arguments]    ${packageName}
    log    Uploading a package to OSM   
    Set Headers    {"Content-Type": "application/json", "Authorization" : "${bearer}" } 
    ${yaml}=    Get Binary File    ${packageName}
    ${body}=   Yaml To Json    ${yaml}
    ${resp}=     POST     ${OSM}:9999/osm/vnfpkgm/v1/vnf_packages_content   ${body}  
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

Upload A TGO To Osm
    log    Uploading a package to OSM via VNV
    ${data}=     Create Dictionary      service_name=IoT_Mobius_NS    service_vendor=Easy Global Market       service_version=2.0      service_platform=osm-2      instance_name=egm-test         callback=http://localhost:5001/callback_tests
    ${body}=     json.Dumps      ${data}
    ${resp}=     POST     ${ADAPTER_ENDPOINT}/instantiate_service   ${body}  
    log to console       \nresponse instantiating service:\n${resp}    