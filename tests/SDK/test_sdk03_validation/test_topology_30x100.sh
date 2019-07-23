#!/bin/bash

FILE="results/topology_$( date +%Y-%m-%d_%H-%M-%S ).csv"
printf "Runtime (s),Max memory (kb)\n" >> $FILE
for j in `seq 1 30`; do
	for i in `seq 1 100`; do
		printf "Running i:${i} j:${j}\n"
		cmd="tng-sdk-validate -t --project "./project_${i} #path to projects folder
		printf "${cmd} j: ${j} i: ${i}\n"
		/usr/bin/time --output=$FILE -a --format='%U,%M' --quiet ${cmd}
	done
done
printf "Done. Results in ${FILE}\n"
