#!/bin/bash
#
# Shell script for the integration test number 11 of 5GTango: Terminate a NetSlice Instantiation (NSI)
#


#Step 1: Submit the valid NSI termination request to the REST API Keep checking the status of the request until the response contains
 
#Step 2: a status field with value success (or failed) Use the NSI instance UUID passed to the request to verify that the records
 
#Step 3: resemble the terminated state.

#Step 4: Check if the NSI has been terminated on the VIM.
