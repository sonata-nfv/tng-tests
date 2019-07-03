#!/bin/bash

# test: create projects with increasing num of VNFs and measure performance
# prerequisit: 
# - install tng-sdk-project (and activate the venv)
# - delete all projects in the "projects" folder (not the folder itself)

FILE="results/$( date +%Y-%m-%d_%H-%M-%S ).csv"
printf "Running test_sdk01_project_management\n"
printf "runtime(s),max memory(kb)\n" >> $FILE
for i in `seq 1 1000`; do
	cmd="tng-project -p "projects/test_prj${i}" --vnfs $i"
	printf "${cmd}\n"
	# record time (s) and max memory (kb) and save to file (append)
	/usr/bin/time --output=$FILE -a --format='%U,%M' --quiet ${cmd}
done
printf "Done. Results in ${FILE}\n"
