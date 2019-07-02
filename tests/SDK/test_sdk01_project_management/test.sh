#!/bin/bash

# test: create projects with increasing num of VNFs and measure performance
# prerequisit: 
# - install tng-sdk-project (and activate the venv)
# - delete all projects in the "projects" folder (not the folder itself)

printf "Running test_sdk01_project_management"
for i in `seq 1 2`; do
	cmd="tng-project -p "projects/test_prj${i}" --vnfs $i"
	printf "${cmd}\n"
	result="$( /usr/bin/time -f '%U,%M' ${cmd} )"
	printf "${result}\n\n"
done
printf "Done"
