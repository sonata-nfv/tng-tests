#!/bin/bash

#STEP 1: - Get all consumers from son-broker
echo -e "STEP 1: Get all consumers from son-broker and add them into consumers.json"
get_messages=$(curl -s -X GET http://guest:guest@pre-int-sp-ath.5gtango.eu:15672/api/consumers > consumers.json)
echo -e "Consumers added in consumers.json"


#STEP 2: - Get queue names that have consumer
echo -e "STEP 2: Get queue names that have consumer and add them into queueNames.json"
cat consumers.json | jq '.[].queue.name' | tr -d \" > queueNames.txt
echo -e "Queues added in queueNames.txt"

COUNTER=0
while IFS='' read -r line || [[ -n "$line" ]];
do
	if [ "$line" == "slas.service.instances.create" ] || [ "$line" == "slas.service.instance.terminate" ] || [ "$line" == "slas.tng.sla.violation" ] || [ "$line" == "slas.son.monitoring.SLA" ]
then
	let COUNTER=COUNTER+1 
fi
done < queueNames.txt

if [ $COUNTER -eq 4 ]; then
	echo "Test Passed - All SLA queues are consuming from the topics"
else
	echo "/n Test Failed - Thread crashed"
fi
