#!/bin/bash

#STEP 1: - Add Moke NS Instance
echo -e "Create a moke service instance with id 5baca658-3b70-488c-931b-4001a7ce8e48 "
create_service=$(curl -s -X POST http://pre-int-sp-ath.5gtango.eu:8000/api/v1/service/new -d @moke_srv.json -H "Accept: application/json" -H "Content-Type: application/json")
echo $create_service

#STEP 2: Get Service Instance
echo -e "\nGet moke Service Instance"
get_service=$(curl -s http://pre-int-sp-ath.5gtango.eu:8000/api/v1/service/5baca658-3b70-488c-931b-4001a7ce8e48/ -H "Accept: application/json" -H "Content-Type: application/json")
echo $get_service

#STEP 3: Send SLA rules
echo -e "\nCreate SLA rules"
send_rules=$(curl -s -X POST http://pre-int-sp-ath.5gtango.eu:8000/api/v1/slamng/rules/service/5baca658-3b70-488c-931b-4001a7ce8e48/configuration -d @sla_rules.json -H "Accept: application/json" -H "Content-Type: application/json")
echo $send_rules

#STEP 4: Get the SLA rules
echo -e "\nGet the SLA Rules"
RULES=$(curl -s -X GET -H "Content-Type: application/json" http://pre-int-sp-ath.5gtango.eu:8000/api/v1/slamng/rules)
count=$(echo "$RULES" | jq '.count' )

if [ $count -gt 0 ]
then
echo "Rules were sent succsefully: True"
fi

#STEP 5: Delete Moke service
echo -e "\nMoke Service Deleted"
del_service=$(curl -s -X DELETE http://pre-int-sp-ath.5gtango.eu:8000/api/v1/services/5baca658-3b70-488c-931b-4001a7ce8e48/  -H "Accept: application/json" -H "Content-Type: application/json")
echo $del_service




