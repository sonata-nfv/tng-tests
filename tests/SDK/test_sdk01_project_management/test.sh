#!/bin/bash

# test: create projects with increasing num of VNFs and measure performance
# prerequisit: 
# - install tng-sdk-project (and activate the venv)
# - delete all projects in the "projects" folder (not the folder itself)

printf "Running test_sdk01_project_management; writing results to results.csv"
printf "runtime(s),max memory(kb)\n" >> "results/results.csv"
for i in `seq 1 2`; do
	cmd="tng-project -p "projects/test_prj${i}" --vnfs $i"
	printf "${cmd}\n"
	# record time (s) and max memory (kb) and save to file (append)
	/usr/bin/time --output='results/results.csv' -a --format='%U,%M' --quiet ${cmd}
done
printf "Done"
