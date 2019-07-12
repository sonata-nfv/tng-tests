#!/bin/bash

# test: create projects with increasing num of VNFs and measure performance
# prerequisit: 
# - install tng-sdk-project (and activate the venv)
# - delete all projects in the "projects" folder (not the folder itself)

# clean projects folder
rm -rf projects/test_prj*

FILE="results/$( date +%Y-%m-%d_%H-%M-%S ).csv"
printf "Running test_sdk01_project_management\n"
printf "Runtime (s),Max memory (kb)\n" >> $FILE
for j in `seq 1 30`; do
	for i in `seq 1 100`; do
		cmd="tng-project -p "projects/test_prj${i}" --vnfs $i"
		printf "${cmd}\n"
		# record time (s) and max memory (kb) and save to file (append)
		/usr/bin/time --output=$FILE -a --format='%U,%M' --quiet ${cmd}
	done
	# clean projects folder
	rm -rf projects/test_prj*
done
printf "Done. Results in ${FILE}\n"
