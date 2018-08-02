#!/bin/bash

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
  -d '{"descriptor_schema": "https://raw.githubusercontent.com/sonata-nfv/tng-schema/master/policy-descriptor/policy-schema.yml","name": "samplepolicydemo1000","vendor": "tango","version": "0.2","network_service": {"vendor":"tango","name":"default-nsd","version": "0.9"},"policyRules": [{"name": "actionUponAlert1","salience": 1,"inertia":{"value": 30,"duration_unit": "m"},"conditions": {"condition": "AND","rules": [{"id":"vnf1.LogMetric","field":"vnf1.LogMetric","type": "string","input": "text","operator":"equal","value":"mon_rule_vm_cpu_perc"}]},"actions": [{"action_object":"ComponentResourceAllocationAction","action_type": "InfrastructureType","name": "ApplyFlavour","value": "3","target": "vnf1"}]},{"name": "highTranscodingRateRule","salience": 1,"inertia": {"value": 30,"duration_unit":"m"},"duration": {"value": 10,"duration_unit": "m"},"aggregation":"avg","conditions": {"condition":"AND","rules": [{"id": "vnf1.CPULoad","field": "vnf1.CPULoad","type": "double","input": "number","operator": "greater","value": "70"},{"id": "vnf2.RAM","field": "vnf2.RAM","type":"integer","input": "select","operator":"less","value": "8"}]},"actions":[{"action_object":"ComponentResourceAllocationAction","action_type":"InfrastructureType","name":"ApplyFlavour","value":"3","target": "vnf1"}]}]}'
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
echo

# Set a policy as default - bind it with an sla_id
echo '-------------------------------------------------'
echo 'Set a policy as default - bind it with an sla_id'
echo '-------------------------------------------------'

policy_metadata=$(curl -X PATCH ""$upload"/""$policy_uuid"  -H 'content-type: application/json' -d '{"slaid":"f9808098980","defaultPolicy":true,"nsid":"e68aeee88a704249ab2dc03eda6b3e8b1"}')

echo
echo $policy_metadata
echo

# Activate a policy
echo '------------------------------------------------------'
echo 'Activate a policy with uuid' $policy_uuid
echo '------------------------------------------------------'

activated_policy=$(curl -X POST \
  ""$upload"/""e68aeee88a704249ab2dc03eda6b3e8b1/activation"   \
  -H 'content-type: application/json' \
  -d '{
  "policy_uuid": "'$policy_uuid'",
  "nsr_uuid": "e68aeee88a704249ab2dc03eda6b3e8b1"
  
}')

echo
echo $activated_policy
echo

# Delete a policy
echo '------------------'
echo 'Delete a policy'
echo '------------------'

deleted_policy=$(curl -X DELETE ""$upload"/""$policy_uuid")
echo
echo $deleted_policy
echo










