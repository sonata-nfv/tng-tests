#!/bin/bash
#
# Shell script for the integration test number 11 of 5GTango: instantiate a network Slice
# The file is divided in 3 parts:
#     - Preparation of the test
#     - Integration test
#     - Cleaning the environment


#Function to find a field within a json structure
function jsonval {
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop`
    echo ${temp##*|}
}

#----------------------------------------------------------------------------------------
#---------------------------------- TEST PREPARATIONS -----------------------------------
#----------------------------------------------------------------------------------------
#Preparing Test Step 0: Preparing the test environment --> NetSlice Template creation
echo "###### PREPARING STEP 0 ######"
json=$(curl -i -X GET http://int-sp-ath.5gtango.eu:32002/api/v3/services)
string_uuid_services=$(printf "$json" | grep -Po 'uuid":"\K[^"]+')
data=`python NST_json_structure.py $string_uuid_services 2>&1 >/dev/null`
json=$(curl -i -H "Content-Type: application/json" -d"$data" -X POST http://int-sp-ath.5gtango.eu:5998/api/nst/v1/descriptors)
prop='uuid'
json_nst_uuid=`jsonval`
nst_uuid=${json_nst_uuid##* }
echo $nst_uuid

STATUS=$(curl -s -o /dev/null -w '%{http_code}' -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://int-sp-ath.5gtango.eu:5998/api/nst/v1/descriptors/${nst_uuid})
if [ $STATUS -eq 200 ]
then
  echo "Got 200! :) Network Slice Template in catalogues."
else
  echo "Got $STATUS :( Network Slice Instance not in repos."
fi

#Preparing Test Step 1: Create the Network Service Instance (NSI) request by submitting NST UUIDs
data=`python NSI_json_structure.py $nst_uuid 2>&1 >/dev/null`
json= curl -k -H "Content-Type: application/json" -d "$data" -X POST http://int-sp-ath.5gtango.eu:5998/api/nsilcm/v1/nsi  > created_nsi.json
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

STATUS=$(curl -s -o /dev/null -w '%{http_code}' -H "Accept: application/json Content-Type: application/json" -X GET http://int-sp-ath.5gtango.eu:5998/api/nsilcm/v1/nsi/{$nsi_uuid})
if [ $STATUS -eq 200 ]
then
  echo "Got 200! :) Network Slice Instance in repositories."
else
  echo "Got $STATUS :( Network Slice Instance not in repos."
fi

#----------------------------------------------------------------------------------------
#------------------------------ INTEGRATION TEST 11 STEPS -------------------------------
#----------------------------------------------------------------------------------------
#Step 1: Submit the valid NSI termination request to the REST API
#Step 2: Keep checking the status of the request until the response contains a status field with value success (or failed)
echo "###### STEPS 1/2 ######"
curl -k -H "Content-Type: application/json" -X POST -d '{"terminateTime": "0"}' http://int-sp-ath.5gtango.eu:5998/api/nsilcm/v1/nsi/${nsi_uuid}/terminate > terminated_nsi.json

#Step 3: Use the NSI instance UUID passed to the request to verify that the records resemble the terminated state.
echo "###### STEPS 3 ######"
ns_instance_state=$(
python - <<EOF
import json, sys;
json_data = open('terminated_nsi.json')
data = json.load(json_data)
netslice_instance_state = data['nsiState']
json_data.close()
print(netslice_instance_state)
EOF
)
echo $ns_instance_state

if [ "$ns_instance_state" == "TERMINATED" ]; then
  echo "Got 200! Service instance is terminated!! :)."
else
  echo "Got $STATUS :( Service instance not terminated."
fi

#Step 4: Check if the NSI has been terminated on the VIM.
#TODO:?¿?¿?¿?


#----------------------------------------------------------------------------------------
#------------------------------ ENVIRONMENT CLEAN PROCESS -------------------------------
#----------------------------------------------------------------------------------------
#Leaving environment as it was initially --> Requests, slices, templates services removal
echo "###### CLEANING ENVIRONMENT STEP ######"
#removes all the network slice intances created in this test
curl -X DELETE http://int-sp-ath.5gtango.eu:4012/records/nsir/ns-instances/{$nsi_uuid}
echo
#removes all the network templates created in this test
curl -X DELETE http://int-sp-ath.5gtango.eu:4011/api/catalogues/v2/nsts/{$nst_uuid}