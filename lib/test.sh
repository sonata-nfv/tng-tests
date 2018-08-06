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



#cleanPackages "$env"

#uploadPackage "$env" "../commons/5gtango-ns-package-example.tgo"


getPackage "$env" "ns-package-example" "0.1" "eu.5gtango"
echo $Package_uuid
echo $Package_status


getService "$env" "myns" "0.1" "eu.5gtango"
echo $Service_uuid
echo $Service_status





#uploadPackage "$env" "../commons/5gtango-ns-package-example.tgo"
#echo $Result

#getService "$env" "myns" "0.1" "eu.5gtango"
#echo $Service
#echo $Service_uuid
#echo $Service_status

#getPackage "$env" "ns-package-example" "0.1" "eu.5gtango"
#echo $packages
#echo $Package
#echo $Package_uuid
#echo $Package_status




#	getPackages "$env"
#	echo $Result

#	getServices "$env"
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





