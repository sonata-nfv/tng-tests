#!/bin/bash

## importing the functions file

. ./functions.lib

## Setting the environment

setEnvironment "$1"
#logger "This is your selected environment:  $env"


## Executing get package and showing some values

#getPackage "$env" "ns-package-example" "0.1" "eu.5gtango"
#echo "Pkg uuid: "$Package_uuid
#echo "Pkg Staus: "$Package_status

getPackage -e "int-sp-ath.5gtango.eu" -n "ns-package-example" -v "0.1" -d "eu.5gtango"
echo "Pkg uuid: "$Package_uuid
echo "Pkg Staus: "$Package_status


usage="\nTo use this function you must specify the following options:\n\n-e: environment\n-n: name of the package\n-v: version of the package \n-d: vendor of the package\n\nExample:\n\ngetPackage -e "int-sp-ath.5gtango.eu" -n "ns-package-example" -v "0.1" -d "eu.5gtango"\n"

while getopts ":e:n:v:d:" option; do
    case "${option}" in
        e) env=${OPTARG};;
        n) name=${OPTARG};;
        v) version=${OPTARG};;
        d) vendor=${OPTARG};;
        :) echo "Missing option argument for -$OPTARG" >&2; return 1;;
	*) echo "Unimplemented option: -$OPTARG" >&2; return 1;;
   	\?) echo "Unknown option: -$OPTARG" >&2; return 1;;
    esac
done

echo
echo $env
echo $name
echo $version
echo $vendor
echo

if [ ! "$env" ] || [ ! "$name" ] || [ ! "$version" ] || [ ! "$vendor" ]
then
    echo $usage
    return 1
fi






