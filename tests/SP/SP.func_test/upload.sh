#!/bin/bash

#instantiating the NS
instantiate=$(awk '/instantiate_ns/ {print $2}' envfile.yml)
echo $instantiate

services=$(awk '/services_host/ {print $2}' envfile.yml)
echo $services
echo
ns_uuid=$(curl  ""$services"" | jq '.[0].uuid')
echo
echo "the ns uuid is: "$ns_uuid
echo
requesting="curl -v -i -H content-type:application/json -X POST ""$instantiate""  -d {"\"service_uuid"\":""$ns_uuid""}"
echo
echo "this is the requesting curl:" 
echo $requesting
echo
#instantiating=$(curl -v -i -H content-type:application/json -X POST ""$instantiate""  -d '{"\"service_uuid"\":""$ns_uuid""}')
instantiating=$($requesting)
echo $instantiating

