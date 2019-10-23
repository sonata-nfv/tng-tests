#!/bin/bash

source /app/config.cfg

mkdir -p /output/${PROBE}/${HOSTNAME}

echo "Traffic generator configuration: "
echo -e "Results file: "$RESULTS_FILE
echo -e "Details file: "$DETAILS_FILE
echo -e "Protocol: "$PROTOCOL
echo -e "External IP: "$EXTERNAL_IP
echo -e "Port: "$PORT
echo -e "Url path: "$URL_PATH
echo -e "Connections: "$CONNECTIONS
echo -e "Duration: "$DURATION
echo -e "Threads: "$THREADS
echo -e "Header: "$HEADER
echo -e "Timeout: "$TIMEOUT
echo -e "Rate: "$RATE
echo -e "Proxy: "$PROXY

if [ -z $PROTOCOL ] || [ -z $EXTERNAL_IP ] || [ -z $PORT ]; then
  echo "Endpoint was not set" > $RESULTS_FILE
  exit 1
else
  URL="${PROTOCOL}://${EXTERNAL_IP}:${PORT}"
fi

if [ -z $HEADER ]; then
  HEADER=""
else
  HEADER="--header $HEADER"
fi

if [ "$PROXY" = "yes" ]; then
  config="/app/result_proxy.lua"
else
  config="/app/result.lua"
fi

#Checking service availability 1 min
connection=false
for i in {1..10}
do
 echo "Trying to connect to ${EXTERNAL_IP}:${PORT}. Try: $i"
 test=$(nc -n -z -v -w1 $EXTERNAL_IP $PORT 2>&1)
 if [[ $test == *open* ]] || [[ $test == Connection*succeeded ]]; then
   connection=true
   echo "Connection SUCCEEDED"
   break
 fi
sleep 6
done

if [ "$connection" = false ] ; then
   echo "Connection FAILED"
   exit 1
fi

echo "COMMAND: /usr/local/bin/wrk -s $config -c $CONNECTIONS -d $DURATION -t $THREADS --timeout $TIMEOUT -R $RATE -H $HEADER --latency $URL"
/usr/local/bin/wrk -s $config -c $CONNECTIONS -d $DURATION -t $THREADS --timeout $TIMEOUT -R $RATE -H $HEADER --latency $URL > $RATE.tmp
cat $RATE.tmp >>  $RESULTS_FILE
/bin/cat $RATE.tmp | tail -58 | jq '{ requests, duration_in_microseconds, bytes, requests_per_sec, bytes_transfer_per_sec, latency_distribution }' > rate-$RATE.json
/bin/cat $RATE.tmp | tail -58 | jq '{ graphs }' > graphs-$RATE.json
/bin/cat $RATE.tmp | tail -58 | jq "{ requests_per_sec, \"requests\": $RATE }" > overall-$RATE.json

# Processing data

# Creating details.json file

# Obtain the json generated list
jsondetail=`echo '{"details": [] }' | jq .`
join_json=`cat rate-$RATE.json`
jsondetail=`echo $jsondetail | jq ".details[0] +=  $join_json"`
jsondetail=`echo $jsondetail | jq [.]`
echo $jsondetail | jq . > details.json

# Creating graphs object
graphs=`echo '{"graphs": [] }' | jq .`

# Adding data to graphs object
join_json=`cat graphs-$RATE.json | jq .graphs`
graphs=`echo $graphs | jq ".graphs += $join_json"`

echo $graphs | jq .graphs > graphs.json
graphs=`echo $graphs | jq .graphs`

# Variables initialization
# Graph template
json=`echo '{"graphs": [ { "title": "Http Benchmark test", "x-axis-title": "Iteration #", "x-axis-unit": "#", "y-axis-title": "Requests per second", "y-axis-unit": "rps", "type": "line", "series": { "s1": "requests_processed", "s2": "requests_sent" }, "data": { "s1x": [], "s1y": [], "s2x": [], "s2y": [] } }]} '`

# Adding data to graphs object
join_json=`cat overall-$RATE.json`
#echo "join_json $join_json"

s1=`echo $join_json | jq '.requests_per_sec'`
s2=`echo $join_json | jq '.requests'`
json=`echo $json | jq ".graphs[0].data.s1x += [1]"`
json=`echo $json | jq ".graphs[0].data.s1y += [$s1]"`
json=`echo $json | jq ".graphs[0].data.s2x += [1]"`
json=`echo $json | jq ".graphs[0].data.s2y += [$s2]"`

echo $json | jq . > requests.json
#echo $graphs

final_graph_object=`echo $json | jq ".graphs += $graphs"`
the_graphs=`echo $final_graph_object | jq '.graphs'`
#echo "the_graphs" $the_graphs

detail_json=`echo $jsondetail | jq ". += [$final_graph_object]"`
the_json=`echo $jsondetail | jq '.[].details'`
detail_sin=`echo $detail_json | jq "{ details: $the_json, graphs: $the_graphs}"`
echo  $detail_sin | jq . > $DETAILS_FILE
#echo "detail_sin" $detail_sin
