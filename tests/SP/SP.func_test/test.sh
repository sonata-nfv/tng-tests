#!/bin/bash

delete_sp=$(awk '/delete_sp/ {print $2}' envfile.yml)
echo $delete_sp

Clean=$(curl -X DELETE  ""$delete_sp"")


upload=$(awk '/upload_package/ {print $2}' envfile.yml)
echo $upload

Result=$(curl -v -i -X POST  -F "package=@./5gtango-ns-package-example.tgo" ""$upload"")


echo $Result



package_process_uuid=$(printf "$Result" | grep -Po 'package_process_uuid":"\K[^"]+')

echo

echo $package_process_uuid



sleep 15



status_url=$upload"/status/"$package_process_uuid

echo

echo $status_url



status=$(curl ""$upload"/status/""$package_process_uuid")

echo

echo $status

echo



package_id=$(printf "$status" | grep -Po 'package_id":"\K[^"]+')

echo

echo $package_id

echo


tavern-ci addsla.yml --stdout --debug 

ns_uuid=$(curl  http://pre-int-sp-ath.5gtango.eu:32002/api/v3/services | jq '.[0].uuid')
echo
echo "the ns uuid is: "$ns_uuid


slaid=$(curl http://pre-int-sp-ath.5gtango.eu:32002/api/v3/slas/templates | jq '.[0].uuid')
echo
echo "the sla uuid is: "$slaid


########policy 
upload=$(awk '/upload_policy/ {print $2}' envfile.yml)
echo $upload

# Create a new policy
echo '------------------'
echo 'Create a new policy'
echo '------------------'

Result=$(curl -X POST \
  $upload \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -d '{"descriptor_schema": "https://raw.githubusercontent.com/sonata-nfv/tng-schema/master/policy-descriptor/policy-schema.yml","name": "samplepolicydemo123456","vendor": "tango","version": "0.2","network_service": {"vendor":"tango","name":"default-nsd","version": "0.9"},"policyRules": [{"name": "actionUponAlert1","salience": 1,"inertia":{"value": 30,"duration_unit": "m"},"conditions": {"condition": "AND","rules": [{"id":"vnf1.LogMetric","field":"vnf1.LogMetric","type": "string","input": "text","operator":"equal","value":"mon_rule_vm_cpu_perc"}]},"actions": [{"action_object":"ComponentResourceAllocationAction","action_type": "InfrastructureType","name": "ApplyFlavour","value": "3","target": "vnf1"}]},{"name": "highTranscodingRateRule","salience": 1,"inertia": {"value": 30,"duration_unit":"m"},"duration": {"value": 10,"duration_unit": "m"},"aggregation":"avg","conditions": {"condition":"AND","rules": [{"id": "vnf1.CPULoad","field": "vnf1.CPULoad","type": "double","input": "number","operator": "greater","value": "70"},{"id": "vnf2.RAM","field": "vnf2.RAM","type":"integer","input": "select","operator":"less","value": "8"}]},"actions":[{"action_object":"ComponentResourceAllocationAction","action_type":"InfrastructureType","name":"ApplyFlavour","value":"3","target": "vnf1"}]}]}'
)

echo 'Result'
echo $Result

policy_uuid=$(printf "$Result" | grep -Po 'uuid":"\K[^"]+')
echo
echo 'policy uuid'
echo $policy_uuid


# Fech a policy
echo '------------------'
echo 'Fech a policy'
echo '------------------'

created_policy=$(curl -X GET ""$upload"/""$policy_uuid")
echo
echo $created_policy
echo

# Fech a list of policies
echo '------------------------'
echo 'Fech a list of policies'
echo '-------------------------'

policies_list=$(curl -X GET $upload)
echo
echo $policies_list

policy_id=$(curl $upload | jq '.[0].uuid')
echo
echo "policy uuid: "$policy_id

# Set a policy as default - bind it with an sla_id
echo '-------------------------------------------------'
echo 'Set a policy as default - bind it with an sla_id'
echo '-------------------------------------------------'

policy_metadata=$(curl -X PATCH ""$upload"/""$policy_id"  -H 'content-type: application/json' -d '{"slaid":""$slaid"","defaultPolicy":true,"nsid":""$ns_uuid""}')

echo
echo $policy_metadata
echo

