#!/bin/bash

unset env
 ## loading environment
. ./envfile
logger "This is your selected environment:  $env"

## importing the functions file
. ./functions.lib

envfile=$1
#echo $envfile


if [ -z "$1" ] 
then
	echo
	logger "Invalid environment for this test script"		
	exit 1
	
else	
	getPackage "$env" "ns-package-example" "0.1" "eu.5gtango"
	echo $Package_uuid
	echo $Package_status
fi





