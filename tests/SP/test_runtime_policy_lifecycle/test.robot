*** Settings ***
Documentation     Test suite for enforcing a Runtime Policy to the SP platform
Library           tnglib

*** Variables ***
${HOST}                http://int-sp-ath.5gtango.eu   #  the name of SP we want to use
${FILE_SOURCE_DIR}     ./packages   # to be modified and added accordingly if package is not on the same folder as test
${FILE_NAME}           eu.5gtango.ns-squid-haproxy.0.1.tgo    # The package to be uploaded and tested

*** Test Cases ***
Setting the SP Path
    Set SP Path     ${HOST}
    ${result} =     Sp Health Check
    Should Be True   ${result}
Upload the Package
    ${result} =     Upload Package      ${FILE_SOURCE_DIR}/${FILE_NAME}
    Should Be True     ${result[0]}
    Set Suite Variable     ${PACKAGE_UUID}  ${result[1]}
    Log     ${PACKAGE_UUID}
#Remove the Package
#    ${result} =     Remove Package      ${PACKAGE_UUID}
#    Should Be True     ${result[0]}

