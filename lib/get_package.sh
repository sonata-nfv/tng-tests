#!/bin/bash

## importing the functions file

. ./functions.lib

## Setting the environment

setEnvironment "$1"
logger "This is your selected environment:  $env"


## Executing get package and showing some values

getPackage "$env" "ns-package-example" "0.1" "eu.5gtango"
echo "Pkg uuid: "$Package_uuid
echo "Pkg Staus: "$Package_status






