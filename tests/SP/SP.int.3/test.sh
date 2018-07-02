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

name=$(curl ""$upload"/""$package_id" | jq '.pd.package_content[0].id.name')
vendor=$(curl ""$upload"/""$package_id" | jq '.pd.package_content[0].id.vendor')
version=$(curl ""$upload"/""$package_id" | jq '.pd.package_content[0].id.version')

echo "Info from the package:"
echo "name: " $name
echo "vendor: " $vendor
echo "version: " $version
echo


cat_packages=$(awk '/cat_packages/ {print $2}' envfile.yml)

name2=$(curl ""$cat_packages"" -H "content-type: application/json" | jq '.[0].pd.package_content[0].id.name')
vendor2=$(curl ""$cat_packages"" -H "content-type: application/json" | jq '.[0].pd.package_content[0].id.vendor')
version2=$(curl ""$cat_packages"" -H "content-type: application/json" | jq '.[0].pd.package_content[0].id.version')

echo "Info from the catalogue:"
echo "name: " $name2
echo "vendor: " $vendor2
echo "version: " $version2
echo

if [ "$name" = "$name2" ] && [ "$vendor" = "$vendor2" ] && [ "$version" = "$version2" ]
then
    echo "The package is in the catalogue"
    echo
else
    echo "The package is not in the catalogue"
    echo
fi


delete_package=$(curl -X DELETE ""$upload"/""$package_id")
echo
echo $delete_package
echo

