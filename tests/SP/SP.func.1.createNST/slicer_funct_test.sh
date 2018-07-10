#!/bin/bash
#
# Shell script for the functional test to create NST
#

#STEP 1: upload the package
. ./step_1_valid_pkg_stored/Valid_package_is_stored.sh

#STEP 2: create NST
. ./step_3_createNST/Create_NST_test.sh