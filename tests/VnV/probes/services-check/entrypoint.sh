#!/bin/bash

source /app/config.cfg

mkdir -p /output/${PROBE}/${HOSTNAME}

echo "Services check test: "
echo "Results file: "$RESULTS_FILE
echo "VNF External IP: "$EXTERNAL_IP
echo "Services to check: "$SERVICES
echo "User: "$USER
echo "Password: "$PASS


if  [ -z $EXTERNAL_IP ]; then
  echo "Invalid external IP" > $RESULTS_FILE
  exit 1
else
  opt1="$EXTERNAL_IP"
fi


arr=$(echo $SERVICES | tr " " "\n")


for serv in $arr
do
	echo $serv

	VAR=$(sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no "$USER"@$ip service $serv status )
	echo $VAR
	
	if echo $VAR | grep -q "inactive"; then
		echo "The Service $serv is Inactive" >> $RESULTS_FILE
	else
		echo "The Service $serv is Active" >> $RESULTS_FILE
	fi

done




