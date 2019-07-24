*** Settings ***
Documentation     Test for stateful VNF migration
Library           tnglib
Library           Collections
Library           RabbitMq
Library           yaml

*** Variables ***
${SP_HOST}      http://int-sp-ath.5gtango.eu
${FILE_SOURCE_DIR}  ../../../packages
${NS_PACKAGE_NAME}  eu.5gtango.test-ns-nsid1c.0.1.tgo
${NS_PACKAGE_SHORT_NAME}  test-ns-nsid1c
${READY}       READY
${PASSED}      PASSED
${INFRA_FILE_PATH}    ../infra.yaml
${First_VIM}     athens-k8s
${Second_VIM}     aveiro-k8s

*** Test Cases ***
Setting the SP Path
    Set SP Path     ${SP_HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
Ensure that two k8s vims are available
    ${result} =      Clean Infrastructure
    ${result_vim1} =      Post Vim From File     ${First_VIM}    ${INFRA_FILE_PATH}
    log      ${result_vim1}
    ${result_vim2} =      Post Vim From File     ${Second_VIM}    ${INFRA_FILE_PATH}
    log      ${result_vim2}
    Should Be True     ${result_vim1[0]}
    Should Be True     ${result_vim2[0]}
    ${data} =     Get Vims      k8s
    Log      ${data[1]}
    Set Suite Variable      ${vims}     ${data[1]}
Clean the Package Before Uploading
    @{packages} =   Get Packages
    log     ${NS_PACKAGE_SHORT_NAME}
    log     ${packages[1]}
    FOR     ${package}  IN  @{packages[1]}
        Run Keyword If     '${package['name']}'== '${NS_PACKAGE_SHORT_NAME}'    Remove Package      ${package['package_uuid']}
    END 
Onboard the NS Package
    log     ${FILE_SOURCE_DIR}
    log     ${NS_PACKAGE_NAME}
    ${result} =      Upload Package     ${FILE_SOURCE_DIR}/${NS_PACKAGE_NAME}
    Log     ${result}
    Should Be True     ${result[0]}
    ${service} =     Map Package On Service      ${result[1]}
    Should Be True     ${service[0]}
    Set Suite Variable     ${service_uuid}  ${service[1]}
    Log     ${service_uuid}
Deploying Service
    ${init} =   Service Instantiate     ${service_uuid}
    Log     ${init}
    Set Suite Variable     ${request}  ${init[1]}
    Log     ${request}    
Wait For Ready
    Wait until Keyword Succeeds     5 min   10 sec   Check Status
    Set SIU   
Obtain VNFR
    ${data} =     Get Service Instance     ${service_instance_uuid}
    ${nsr} =      Set Variable     ${data[1]}
    Set Suite Variable     ${old_vnfr_id}  ${NSR['network_functions'][0]['vnfr_id']}
    Log     ${old_vnfr_id}
    ${DATA} =     Get Function Instance     ${old_vnfr_id}
    Set Suite Variable     ${old_vnfr}  ${data[1]}
    Set Suite Variable     ${old_vim}  ${old_vnfr['cloudnative_deployment_units'][0]['vim_id']}  
    Log     ${old_vim}
# Generate state in the CNF
    # TODO
Request migration event for VNF
    FOR       ${vim}  IN  @{vims}
        Log     ${vim}
        Run Keyword If     '${vim['uuid']}' != '${old_vim}'     Set Suite Variable     ${new_vim}  ${vim['uuid']}
    END
    Log     ${new_vim}
    ${payload} =     Create Dictionary     service_instance_uuid     ${service_instance_uuid}     vnf_uuid     ${old_vnfr_id}     vim_uuid     ${new_vim}
    Log     ${payload}
    ${yamlload} =     evaluate      yaml.dump(${payload})       yaml
    Log     ${yamlload}
    ${properties} =     Create Dictionary     reply_to     service.instance.migrate     correlation_id     ${service_instance_uuid} 
    Log     ${properties}
    Create Rabbitmq Connection    ${SP_HOST[7:]}    15672    5672    guest    guest     None    /
    Publish Message     son-kernel     service.instance.migrate     ${yamlload}     ${properties}
Wait for Migration to Finish
    Wait until Keyword Succeeds     5 min   10 sec   Check Migration Status
Check if Migration was successful
    ${data} =     Get Service Instance  ${service_instance_uuid}
    ${nsr} =      Set Variable     ${data[1]}
    Set Suite Variable       ${new_vnfr_id}  ${nsr['network_functions'][0]['vnfr_id']}     
    Should Not Be Equal     ${new_vnfr_id}  ${old_vnfr_id}
    ${data} =     Get Function Instance     ${new_vnfr_id}
    Set Suite Variable     ${new_vnfr}  ${data[1]}
    Set Suite Variable     ${new_vim}  ${new_vnfr['cloudnative_deployment_units']['vim_id']}  
    LOG     ${new_vim}
    Should Not Be Equal     ${new_vim}  ${old_vim}
# Check if State was transferred correctly
    # TODO
Terminate Service
    ${ter} =    Service Terminate   ${service_instance_uuid}
    Set Suite Variable     ${term_req}  ${ter[1]}
Wait For Terminate Ready    
    Wait until Keyword Succeeds     2 min   5 sec   Check Terminate   
Clean the Package after terminating
    @{PACKAGES} =   Get Packages
    FOR     ${PACKAGE}  IN  @{PACKAGES[1]}
        Run Keyword If     '${PACKAGE['name']}'== '${NS_PACKAGE_SHORT_NAME}'    Remove Package      ${PACKAGE['package_uuid']}
    END   
*** Keywords ***
Check Status
    ${status} =     Get Request     ${request}
    Should Be Equal    ${READY}  ${status[1]['status']}
Check Migration Status
    ${data} =     Get Service Instance   ${service_instance_uuid}
    ${nsr_updated} =      Set Variable   ${data[1]}
    ${vnfr_id} =      Set Variable  ${nsr_updated['network_functions'][0]['vnfr_id']}     
    Log      ${vnfr_id}
    Should Not Be Equal     ${vnfr_id}  ${old_vnfr_id}
Set SIU
    ${status} =     Get Request     ${request}
    Set Suite Variable     ${service_instance_uuid}    ${status[1]['instance_uuid']}
Check Terminate
    ${status} =     Get Request     ${term_req}
    Should Be Equal    ${READY}  ${status[1]['status']}
