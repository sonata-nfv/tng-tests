#!/bin/bash
set -e

echo '-----------------------'
echo 'Check if package exists'
echo '-----------------------'

SERVICE_URL=$(awk '/services_host/ {print $2}' envfile.yml)
SERVICE_UUID=`curl -s $SERVICE_URL | jq --raw-output '.[ ] | select(.nsd.name=="NS-squid-haproxy") | select(.nsd.vendor=="eu.5gtango") | select(.nsd.version=="0.1") | .uuid'`
echo "SERVICE UUID: " $SERVICE_UUID

if [ -z "$SERVICE_UUID" ]; then	

	echo '----------------'
	echo 'Upload package'
	echo '----------------'

	UPLOAD_URL=$(awk '/upload_package/ {print $2}' envfile.yml)
	PACKAGE_UPLOAD=$(curl -v -i -X POST  -F "package=@./eu.5gtango.ns-squid-haproxy.0.1.tgo" ""$UPLOAD_URL"")
	sleep 5
	SERVICE_UUID=`curl -s $SERVICE_URL | jq --raw-output '.[ ] | select(.nsd.name=="NS-squid-haproxy") | select(.nsd.vendor=="eu.5gtango") | select(.nsd.version=="0.1") | .uuid'`
	echo "SERVICE UUID: " $SERVICE_UUID
fi

echo '-------------'
echo 'Instantiation'
echo '-------------'

REQUEST_URL=$(awk '/instantiate_request/ {print $2}' envfile.yml)
REQUEST_PAYLOAD="-d {\"service_uuid\":\"$SERVICE_UUID\"} -H content-type:application/json"
echo $REQUEST_URL
echo $REQUEST_PAYLOAD
INSTANTIATION_ID=`curl -s $REQUEST_URL $REQUEST_PAYLOAD | jq --raw-output '.id'`
echo "INSTANTIATION ID: " $INSTANTIATION_ID
sleep 5
INSTANTIATION_STATUS=`curl -s $REQUEST_URL/$INSTANTIATION_ID | jq -r '.status'`
echo "INSTANTIATION STATUS: " $INSTANTIATION_STATUS

echo '--------------------------------------'
echo 'Waiting for service to be instantiated'
echo '--------------------------------------'

j=0
EXPECTED_STATUS="READY"
echo "EXPECTED STATUS: " $EXPECTED_STATUS
while [ "$INSTANTIATION_STATUS" != "$EXPECTED_STATUS" ]; do

INSTANTIATION_STATUS=`curl -s $REQUEST_URL/$INSTANTIATION_ID | jq -r '.status'`
echo "INSTANTIATION STATUS: " $INSTANTIATION_STATUS

if [ "$INSTANTIATION_STATUS" != "$EXPECTED_STATUS" ]; then
    j=$((j+1))
	echo "SERVICE IS STILL INSTANTIATING:" $j"/30"
    sleep 20
    if [ $j -gt 29 ]; then
    	echo "Service was not instantiated in less than 10 minutes"
    	exit 1
   fi
fi
done

echo '----------------------------------'
echo 'Check if instantiation was correct'
echo '----------------------------------'
INSTANCE_UUID=`curl -s $REQUEST_URL/$INSTANTIATION_ID | jq -r '.instance_uuid'`
echo "INSTANCE UUID:" $INSTANCE_UUID

echo '---------'
echo 'Check NSR'
echo '---------'

NSR_URL=$(awk '/nsr/ {print $2}' envfile.yml)
NSR_STATUS=`curl -s $NSR_URL/$INSTANCE_UUID | jq --raw-output '.status'`
echo $NSR_STATUS

if [ "$NSR_STATUS" != "normal operation" ]; then
	echo "STATUS $NSR_STATUS IS NOT CORRECT"
	exit 1
fi

echo '-----------'
echo 'Check VNFRs'
echo '-----------'
VNFRS=`curl -s $NSR_URL/$INSTANCE_UUID | jq --raw-output '.network_functions'`
for i in $VNFRS; do
	if [[ $i == *[-]* ]]
	then
		VNF_UUID=`echo $i | sed 's:^.\(.*\).$:\1:'`
		echo "VNF UUID: "$VNF_UUID
		VNFR_URL=$(awk '/vnfr/ {print $2}' envfile.yml)
		VNFR_STATUS=`curl -s $VNFR_URL/$VNF_UUID | jq --raw-output '.status'`
		echo $VNFR_STATUS
			if [ "$VNFR_STATUS" != "normal operation" ]; then
				echo "STATUS $VNFR_STATUS IS NOT CORRECT"
				exit 1
			fi
		VNFR_NAME=`curl -s $VNFR_URL/$VNF_UUID | jq --raw-output '.status'`

	fi
done

echo '-------------------------'
echo 'Check if the stack exists'
echo '-------------------------'

os_username=$(awk '/os_username/ {print $2}' envfile.yml)
os_user_domain_name=$(awk '/os_user_domain_name/ {print $2}' envfile.yml)
os_password=$(awk '/os_password/ {print $2}' envfile.yml)
os_project_name=$(awk '/os_project_name/ {print $2}' envfile.yml)
os_auth_url=$(awk '/os_auth_url/ {print $2}' envfile.yml)
os_project_domain_name=$(awk '/os_project_domain_name/ {print $2}' envfile.yml)

export OS_USERNAME=$os_username
export OS_USER_DOMAIN_NAME=$os_user_domain_name
export OS_PASSWORD=$os_password
export OS_PROJECT_NAME=$os_project_name
export OS_AUTH_URL=$os_auth_url
export OS_PROJECT_DOMAIN_NAME=$os_project_domain_name

STACK_LIST=`heat stack-list | head -n-1 | tail -n+4`
echo $STACK_LIST
SUB_STRING="SonataService-"$INSTANCE_UUID
if [[ $STACK_LIST != *$SUB_STRING* ]]; then
	echo "STACK "$SUB_STRING "DOES NOT EXIST"
	exit 1
fi

echo "STACK EXISTS"

echo '----------------------'
echo 'Make a scaling request'
echo '----------------------'

# Obtain Squid VNFD UUID
FUNCTION_URL=$(awk '/functions_host/ {print $2}' envfile.yml)
SQUID_UUID=`curl -s $FUNCTION_URL | jq --raw-output '.[ ] | select(.vnfd.name=="squid-vnf") | select(.vnfd.vendor=="eu.5gtango") | select(.vnfd.version=="0.2") | .uuid'`
echo "SQUID VNFD UUID: " $SQUID_UUID

# Build scaling yaml message
PAYLOAD="---\nscaling_type: addvnf\nservice_instance_id: $INSTANCE_UUID\nvnfd_id: $SQUID_UUID"
echo "$PAYLOAD"

RABBITMQ_BASE=$(awk '/rabbitmq/ {print $2}' envfile.yml)
RABBITMQ_URL=$RABBITMQ_BASE'/api/exchanges/%2f/son-kernel/publish'

HEADER_PAYLOAD="-H 'content-type:application/json'"
SCALE_PAYLOAD="-d '{\"properties\":{\"correlation_id\":\"9fd49511-43e9-4dec-91b6-8fda377818a1\", \"reply_to\":\"service.instance.scale\"},\"routing_key\":\"service.instance.scale\",\"payload\":\""$PAYLOAD"\",\"payload_encoding\":\"string\"}'"

echo $RABBITMQ_URL
echo $HEADER_PAYLOAD
echo $SCALE_PAYLOAD

SCALE_TRIGGER='curl -i -u guest:guest '$HEADER_PAYLOAD' -X POST '$SCALE_PAYLOAD' '$RABBITMQ_URL
echo $SCALE_TRIGGER
eval $SCALE_TRIGGER

# Wait for the scaling event to be completed
sleep 360

echo '------------------------'
echo 'Evaluate scaling request'
echo '------------------------'

echo '-------------'
echo 'Check records'
echo '-------------'

NSR_URL=$(awk '/nsr/ {print $2}' envfile.yml)
VNFRS=`curl -s $NSR_URL/$INSTANCE_UUID | jq --raw-output '.network_functions'`

NUMBER_OF_VNF=0
for i in $VNFRS; do
	if [[ $i == *[-]* ]]
	then
		NUMBER_OF_VNF=$((NUMBER_OF_VNF+1))
		echo $NUMBER_OF_VNF
		VNF_UUID=`echo $i | sed 's:^.\(.*\).$:\1:'`
		echo "VNF UUID: "$VNF_UUID
		VNFR_URL=$(awk '/vnfr/ {print $2}' envfile.yml)
		VNFR_STATUS=`curl -s $VNFR_URL/$VNF_UUID | jq --raw-output '.status'`
		echo $VNFR_STATUS
			if [ "$VNFR_STATUS" != "normal operation" ]; then
				echo "STATUS $VNFR_STATUS IS NOT CORRECT"
				exit 1
			fi
	fi
done
if [ $NUMBER_OF_VNF != 3 ]; then
	echo "NUMBER OF VNFS NOT CORRECT: "$NUMBER_OF_VNF
	exit 1
fi

echo '-----------------------------'
echo 'Check number of VNFs in stack'
echo '-----------------------------'

STACK_ID=`heat stack-list | head -n-1 | tail -n+4 | grep SonataService-$INSTANCE_UUID | awk '{print $2}'`
echo $STACK_ID
NUMBER_OF_VNFS=`heat resource-list $STACK_ID | grep OS::Heat::ResourceGroup | awk '{print $2}' | wc -w`
echo $NUMBER_OF_VNFS

if [ $NUMBER_OF_VNFS != "3" ]; then
	echo "NUMBER OF VNFS NOT CORRECT: "$NUMBER_OF_VNFS
	exit 1
fi

echo '------------------'
echo 'Check SSM/FSM work'
echo '------------------'

VNFR_RECORDS=`curl $NSR_URL/$INSTANCE_UUID | jq .'network_functions[ ].vnfr_id'`

URL_VNFDS=$(awk '/functions_host/ {print $2}' envfile.yml)
HA_PROXY_VNFD_UUID=`curl $URL_VNFDS | jq '.[ ] | select(.vnfd.name=="haproxy-vnf") | .uuid' | cut -d "\"" -f 2`
echo $HA_PROXY_VNFD_UUID

# Obtain the management IP of the haproxy
for i in $VNFR_RECORDS; do
	echo $i
	UUID=`echo $i | cut -d "\"" -f 2`
	echo $UUID
	VNFR_VNFD_REF=`curl $VNFR_URL/$UUID | jq ".descriptor_reference" | cut -d "\"" -f 2`
	echo $VNFR_VNFD_REF
	if [ "$HA_PROXY_VNFD_UUID" == "$VNFR_VNFD_REF" ]; then
		MGMT_IP=`curl $VNFR_URL/$UUID | jq .virtual_deployment_units[0].vnfc_instance[0].connection_points[0].interface.address | cut -d "\"" -f 2`
		echo $MGMT_IP
	fi
done

# CHeck if number of backends is correct. If it is, SSM and FSM are operating correctly.
NUMBER_BACKENDS=`curl http://$MGMT_IP:5000 | grep vnf | wc -l`

if [ $NUMBER_BACKENDS != 2 ]; then
	echo "NUMBER OF BACKENDS $NUMBER_BACKENDS NOT CORRECT"
	exit 1
fi