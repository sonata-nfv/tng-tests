#!/bin/bash
#
# Shell script for the integration test number 6 of 5GTango: Create NST
#

function jsonval {
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop`
    echo ${temp##*|}
}

echo "------TEMPLATE_1: check available services-----"
#STEP 1: Get a list of available services
result=$(curl -k -i -X GET https://int-sp-ath.5gtango.eu/api/v3/services)
sleep 1
echo $result
echo

echo "------TEMPLATE_2: getting the uuid of the service to add into the tempalte-----"
#STEP 2: Save the UUID of the NSDs to be included in the NST
string_uuid_services=$(printf "$result" | grep -Po 'uuid":"\K[^"]+')
echo $string_uuid_services
echo

echo "------TEMPLATE_3: create the template-----"
#STEP 3: Build the NST composed by a list of NSD UUIDs --> {"NsdId":"<NSuuid>"}
data=`python ./step_2_createNST/NST_json_structure.py $string_uuid_services 2>&1 >/dev/null`
echo $data
json=$(curl -k -i -H "Content-Type: application/json" -d "$data" -X POST https://int-sp-ath.5gtango.eu/api/v3/slices)
sleep 1
echo

#STEP 4: Save the returned NST UUID
prop='uuid'
json_nst_uuid=`jsonval`
nst_uuid=${json_nst_uuid##* }
echo $nst_uuid
echo

echo "------TEMPLATE_4: check the template is saved in catalogues-----"
#STEP5: Check that the NST is stored in the Catalogue by querying
STATUS=$(curl -s -o /dev/null -w '%{http_code}' -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://int-sp-ath.5gtango.eu:5998/api/nst/v1/descriptors/${nst_uuid})

if [ $STATUS -eq 200 ]
then
  echo "Got 200! :) Network Slice Template in catalogues."
else
  echo "Got $STATUS :( Network Slice Template not in catalogues."
fi
echo