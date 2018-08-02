#!/bin/bash


echo "------INSTANTIATION_1: creation-----"
#Preparing Test Step 1: Create the Network Service Instance (NSI) request by submitting NST UUIDs
data=`python ./step_3_netslice_inst/NSI_json_structure.py $nst_uuid 2>&1 >/dev/null`
json= curl -k -H "Content-Type: application/json" -d "$data" -X POST http://int-sp-ath.5gtango.eu:5998/api/nsilcm/v1/nsi > created_nsi.json

nsi_uuid=$(
python - <<EOF
import json, sys;
json_data = open('created_nsi.json')
data = json.load(json_data)
list_instance_uuid = data['uuid']
json_data.close()
print(list_instance_uuid)
EOF
)
echo $nsi_uuid
echo

echo "------INSTANTIATION_2: check in repositories -----"
STATUS=$(curl -s -o /dev/null -w '%{http_code}' -H "Accept: application/json Content-Type: application/json" -X GET http://int-sp-ath.5gtango.eu:5998/api/nsilcm/v1/nsi/{$nsi_uuid})

if [ $STATUS -eq 200 ]
then
  echo "Got 200! :) Network Slice Instance in repositories."
else
  echo "Got $STATUS :( Network Slice Instance not in repos."
fi
echo