#!/bin/bash
#
# Shell script for the integration test number 6 of 5GTango: Create NST
#

function jsonval {
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop`
    echo ${temp##*|}
}

echo "------NST_1-----"
#STEP 1: Get a list of available services
result=$(curl -k -i -X GET https://int-sp-ath.5gtango.eu/api/v3/services)
sleep 1
echo $result
echo

echo "------NST_2-----"
#STEP 2: Save the UUID of the NSDs to be included in the NST
string_uuid_services=$(printf "$result" | grep -Po 'uuid":"\K[^"]+')
echo $string_uuid_services
echo

echo "------NST_3-----"
#STEP 3: Build the NST composed by a list of NSD UUIDs --> {"NsdId":"<NSuuid>"}
data=`python ./step_2_createNST/NST_json_structure.py $string_uuid_services 2>&1 >/dev/null`
echo $data
json=$(curl -k -i -H "Content-Type: application/json" -d "$data" -X POST https://int-sp-ath.5gtango.eu/api/v3/slices)
sleep 1
echo

echo "------NST_4-----"
#STEP 4: Save the returned NST UUID
prop='uuid'
json_nst_uuid=`jsonval`
nst_uuid=${json_nst_uuid##* }
echo $nst_uuid
echo

echo "------NST_5-----"
#STEP5: Check that the NST is stored in the Catalogue by querying
url="https://int-sp-ath.5gtango.eu/api/v3/slices/"${nst_uuid}
json=$(curl -k -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET https://int-sp-ath.5gtango.eu/api/v3/slices/${nst_uuid})
sleep 1
echo $json
echo

echo "------NST_6-----"
#STEP 6: Delete the NST 
json=$(curl -k -X DELETE https://int-sp-ath.5gtango.eu/api/v3/slices/{$nst_uuid})
sleep 1
echo

echo "------NST_7-----"
#delete_package=$(curl -k -X DELETE ""$upload"/""$package_id")
delete_package=$(curl -k -X DELETE ${upload}"/"${package_id})
echo