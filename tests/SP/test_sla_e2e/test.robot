*** Settings ***
Documentation     Test suite for uploading a package to the SP platform
Library           tnglib

*** Variables ***
${HOST}                http://pre-int-sp-ath.5gtango.eu   #  the name of SP we want to use
${READY}       READY
${FILE_SOURCE_DIR}     ./packages   # to be modified and added accordingly if package is not on the same folder as test
${FILE_NAME}           eu.5gtango.test-ns-nsid1c.0.1.tgo    # The package to be uploaded and tested


