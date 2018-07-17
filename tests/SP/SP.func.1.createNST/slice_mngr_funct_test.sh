#!/bin/bash
#
# Shell script for the functional test to create NST
#

#package_name="./step_1_valid_pkg_stored/eu.5gtango.ns-haproxy.0.1.tgo"
package_name="./step_1_valid_pkg_stored/5gtango-ns-package-example.tgo"

#STEP 1: upload the package
. ./step_1_valid_pkg_stored/Valid_package_is_stored.sh

#STEP 2: create NST
. ./step_2_createNST/Create_NST_test.sh

#Add integration tests number 8 and 11???