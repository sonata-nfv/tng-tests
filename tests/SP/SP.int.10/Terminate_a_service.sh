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
SUB_STRING="SonataService-"$INSTANCE_UUID
if [[ $STACK_LIST != *$SUB_STRING* ]]; then
	echo "STACK "$SUB_STRING "DOES NOT EXIST"
	exit 1
fi

echo "STACK EXISTS"

echo '---------------------'
echo 'Terminate the service'
echo '---------------------'

REQUEST_URL=$(awk '/instantiate_request/ {print $2}' envfile.yml)
REQUEST_PAYLOAD="-d {\"instance_uuid\":\"$INSTANCE_UUID\",\"request_type\":\"TERMINATE_SERVICE\"} -H content-type:application/json"
echo $REQUEST_URL
echo $REQUEST_PAYLOAD
TERMINATION_ID=`curl -s $REQUEST_URL $REQUEST_PAYLOAD | jq --raw-output '.id'`
echo "TERMINATION ID: " $TERMINATION_ID
sleep 5
TERMINATION_STATUS=`curl -s $REQUEST_URL/$TERMINATION_ID | jq -r '.status'`
echo "TERMINATION STATUS: " $TERMINATION_STATUS

echo '------------------------------------'
echo 'Waiting for service to be terminated'
echo '------------------------------------'

j=0
EXPECTED_STATUS="READY"
echo "EXPECTED STATUS: " $EXPECTED_STATUS
while [ "$TERMINATION_STATUS" != "$EXPECTED_STATUS" ]; do

TERMINATION_STATUS=`curl -s $REQUEST_URL/$TERMINATION_ID | jq -r '.status'`
echo "TERMINATION STATUS: " $TERMINATION_STATUS

if [ "$TERMINATION_STATUS" != "$EXPECTED_STATUS" ]; then
    j=$((j+1))
	echo "SERVICE IS STILL TERMINATING:" $j"/6"
    sleep 20
    if [ $j -gt 5 ]; then
    	echo "Service was not terminated in less than 2 minutes"
    	exit 1
   fi
fi
done

echo '----------------------------------'
echo 'Check if termination was correct'
echo '----------------------------------'

echo '---------'
echo 'Check NSR'
echo '---------'

NSR_URL=$(awk '/nsr/ {print $2}' envfile.yml)
NSR_STATUS=`curl -s $NSR_URL/$INSTANCE_UUID | jq --raw-output '.status'`
echo $NSR_STATUS

if [ "$NSR_STATUS" != "terminated" ]; then
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
			if [ "$VNFR_STATUS" != "terminated" ]; then
				echo "STATUS $VNFR_STATUS IS NOT CORRECT"
				exit 1
			fi
	fi
done

echo '-------------------------'
echo 'Check if the stack exists'
echo '-------------------------'

sleep 30

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
SUB_STRING="SonataService-"$INSTANCE_UUID
if [[ $STACK_LIST = *$SUB_STRING* ]]; then
	echo "STACK "$SUB_STRING "STILL EXISTS"
	exit 1
fi

echo "STACK NO LONGER EXISTS"