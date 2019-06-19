*** Settings ***
Documentation     Test suite for uploading a package to the SP platform
Library           tnglib

*** Variables ***
${HOST}                 http://pre-int-sp-ath.5gtango.eu   #  the name of SP we want to use
${READY}                READY
${FILE_SOURCE_DIR}      ./packages   # to be modified and added accordingly if package is not on the same folder as test
${FILE_SERVICE_NAME}    eu.5gtango.test-ns-nsid1v.0.1.tgo    # The package to be uploaded and tested
${FILE_TEMPLATE_PATH}   NSTD/3nsid1v_nstd.yaml
${NSI_NAME}             slice_test_311
${NSI_DESCRIPTION}       Testing_slice_test_case_3.1.1


*** Test Cases ***
Setting the SP Path
    Set SP Path     ${HOST}
    ${result} =    Sp Health Check
    Should Be True   ${result}

Upload the Package
    ${result} =    Upload Package      ${FILE_SOURCE_DIR}/${FILE_SERVICE_NAME}
    Should Be True     ${result[0]}
    ${service} =    Map Package On Service    ${result[1]}
    Log     ${service}
    Should Be True    ${service[0]}
    Set Suite Variable    ${PACKAGE_UUID}    ${service[1]}
    Log     ${PACKAGE_UUID}

Upload the Slice Template
    ${nst_result} =    Create Slice Template     ${FILE_SOURCE_DIR}/${FILE_TEMPLATE_PATH}
    Log     ${nst_result}
    Should Be True     ${nst_result[0]}
    Set Suite Variable     ${nst_uuid}    ${nst_result[1]}
    Log     ${nst_uuid}

Deploy a Slice instance_uuid
    ${nsi_result} =    Slice Instantiate     ${nst_uuid}    name=${NSI_NAME}    description=${NSI_DESCRIPTION}
    Log     ${nsi_result}
    Should Be True     ${nsi_result[0]}
    Set Suite Variable     ${nsi_uuid}    ${nsi_result[1]}
    Log     ${nsi_uuid}

Wait For Ready
    Wait until Keyword Succeeds     15 min   30 sec   Check Request Status
    Set SIU

Terminate the Slice Instance
    ${nsi_result} =    Slice Terminate     ${nsi_uuid}
    Log    ${nsi_result}
    Should Be True    ${nsi_result[0]}

Wait For Ready
    Wait until Keyword Succeeds     5 min   30 sec   Check Request Status
    Set SIU

Remove Slice Template
    ${nst_result} =   Delete Slice Template     ${nst_result[1]}
    Log     ${nst_result}
    Should Be True     ${nst_result[0]}

Clean the Package
    ${result}=    Remove Package    package_uuid=${PACKAGE_UUID}


*** Keywords ***
Check Request Status
    ${status} =     Get Request    ${REQUEST}
    Should Be Equal    ${READY}    ${status[1]['status']}

Set SIU
    ${status} =     Get Request    ${REQUEST}
    Set Suite Variable    ${INSTANCE_ID}    ${status[1]['instance_uuid']}

Check Terminate
    ${status} =     Get Request    ${TERM_REQ}
    Should Be Equal    ${READY}    ${status[1]['status']}