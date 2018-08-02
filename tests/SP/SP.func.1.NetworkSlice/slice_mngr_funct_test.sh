#!/bin/bash
#
# Shell script for the functional test to create NST
#

package_name="./step_1_valid_pkg_stored/eu.5gtango.ns-haproxy.0.1.tgo"

#STEP 1: Upload the package
. ./step_1_valid_pkg_stored/Valid_package_is_stored.sh

#STEP 2: Create NetSlice Template
. ./step_2_createNST/Create_NST_test.sh

#STEP 3: Create NetSlice Instantiation
. ./step_3_netslice_inst/instantiate_slice_test.sh

#STEP 4: Terminate NetSlice Instantiation (and deletes tempalte, instance and package from db)
. ./step_4_slice_terminate/terminate_slice_test.sh

