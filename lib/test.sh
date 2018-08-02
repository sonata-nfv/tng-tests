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

getService "$env" "NS-squid-haproxy" "0.1" "eu.5gtango"
echo $Result
echo $Service_uuid
echo $Service_status

#	getPackages "$env"
#	echo $Result

#	getServicies "$env"
#	echo $Result	


#	getPolicies "$env"
#	echo $Result

#	getSlas "$env"
#	echo $Result

#	getFunctions "$env"
#	echo $Result

#	getRequests "$env"
#	echo $Result

#	getSlices "$env"
#	echo $Result

#	uploadPackage "$env" "../commons/5gtango-ns-package-example.tgo"
#	echo $Result

fi





