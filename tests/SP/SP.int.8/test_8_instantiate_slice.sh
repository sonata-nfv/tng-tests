#!/bin/bash
#
# Shell script for the integration test number 8 of 5GTango: instantiate a network Slice
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
echo "###### STEP 0 ######"
json=$(curl -i -X GET http://int-sp-ath.5gtango.eu:32002/api/v3/services)
string_uuid_services=$(printf "$json" | grep -Po 'uuid":"\K[^"]+')
data=`python NST_json_structure.py $string_uuid_services 2>&1 >/dev/null`
json=$(curl -i -H "Content-Type: application/json" -d "$data" -X POST http://int-sp-ath.5gtango.eu:5998/api/nst/v1/descriptors)
echo $data
prop='uuid'
json_nst_uuid=`jsonval`
nst_uuid=${json_nst_uuid##* }
echo $nst_uuid
echo


#----------------------------------------------------------------------------------------
#------------------------------ INTEGRATION TEST 8 STEPS --------------------------------
#----------------------------------------------------------------------------------------
#Step 1: Get a list of available NSTs
echo "###### STEP 1 ######"
curl -k -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://int-sp-ath.5gtango.eu:5998/api/nst/v1/descriptors > descriptors_templates.json
list_NST_uuids=$(
python - <<EOF
import json, sys;
json_data = open('descriptors_templates.json')
data = json.load(json_data)
list_uuids = []
for item in data:
  list_uuids.append(item['uuid'])
json_data.close()
print(list_uuids)
EOF
)

echo $list_NST_uuids
echo

##Step 2: Save the UUID of the NSDs included in the NST to be instantiated
echo "###### STEP 2 ######"
curl -k -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://int-sp-ath.5gtango.eu:5998/api/nst/v1/descriptors/{$nst_uuid} > descriptor_nst.json
list_nsd_uuid=$(
python - <<EOF
import json, sys;
json_data = open('descriptor_nst.json')
data = json.load(json_data)
list_nsd_uuid = []
for item in data['nstd']['nstNsdIds']:
  list_nsd_uuid.append(item)
json_data.close()
print(list_nsd_uuid)
EOF
)

echo $list_nsd_uuid
echo

#NOTE: the following 3 steps are done with the next curl request
#Step 3: Create the Network Service Instance (NSI) request by submitting NST UUIDs'
#Step 4: Save the request_uuid returned, for the next step
#Step 5: Keep checking the status of the request until the response contains a status field with value success (or failed)
echo "###### STEP 3/4/5 ######"
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


#Step 6: Save the returned ns_instance_uuid values
echo "###### STEP 6 ######"
string_servinst_uuid=$(
python - <<EOF
import json, sys;
json_data = open('created_nsi.json')
data = json.load(json_data)
list_instance_uuid = []
for item in data['netServInstance_Uuid']:
  list_instance_uuid.append(item)
json_data.close()
print(list_instance_uuid)
EOF
)
echo $string_servinst_uuid
string_servinst_uuid=${string_servinst_uuid#"["}
string_servinst_uuid=${string_servinst_uuid%"]"}
list_ns_instance_uuid=($string_servinst_uuid)
echo $list_ns_instance_uuid


#Step 7: Check that they're the same number as the number of NS that are part of the NST
echo "###### STEP 7 ######"
if [ ${#list_nsd_uuid[@]} -eq  ${#list_ns_instance_uuid[@]} ]; then
    echo "TEST_1_1 OK: SAME number of service instances as services composing NetSlice Template."
else
    echo "TEST_1_1 WRONG: DIFFERENT number of service isntances as services composingthe NetSlice Template."
fi
echo


#Step 8: Check that they've been stored in the Repositories
echo "###### STEP 8 ######"
STATUS=$(curl -s -o /dev/null -w '%{http_code}' -H "Accept: application/json Content-Type: application/json" -X GET http://int-sp-ath.5gtango.eu:5998/api/nsilcm/v1/nsi/{$nsi_uuid})
if [ $STATUS -eq 200 ]
then
  echo "Got 200! Network Slice Instance in repos."
else
  echo "Got $STATUS :( Network Slice Instance not in repos."
fi


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