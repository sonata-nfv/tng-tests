#!/bin/bash


echo "------TERMINATION_1: sending reuqest to terminate slice-----"
curl -k -H "Content-Type: application/json" -X POST -d '{"terminateTime": "0"}' http://int-sp-ath.5gtango.eu:5998/api/nsilcm/v1/nsi/${nsi_uuid}/terminate > terminated_nsi.json

#Use the NSI instance UUID passed to the request to verify that the records resemble the terminated state.
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
echo

echo "------TERMINATION_2: Cleaning objects created------"
#removes all the network slice intances created in this test
curl -X DELETE http://int-sp-ath.5gtango.eu:4012/records/nsir/ns-instances/${nsi_uuid}
echo
#removes the network template created in this test
curl -X DELETE http://int-sp-ath.5gtango.eu:4011/api/catalogues/v2/nsts/${nst_uuid}
echo
#delete_package=$(curl -k -X DELETE ""$upload"/""$package_id")
delete_package=$(curl -k -X DELETE ${upload}"/"${package_id})
echo


echo "----------------------------------------------------------------------"
echo "----------------------- END OF FUNCTIONAL TEST -----------------------"
echo "----------------------------------------------------------------------"