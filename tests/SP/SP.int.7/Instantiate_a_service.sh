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

mon=$(awk '/monitoring/ {print $2}' envfile.yml)
echo
echo "mon" $mon
echo
monitoring=$(curl ""$mon"/""$package_id")
echo
echo $monitoring
echo

delete_package=$(curl -X DELETE ""$upload"/""$package_id")
echo
echo $delete_package
echo

