#!/bin/bash
job_start=201
job_end=833
conf_chain="s4"
log_path="/home/clusters/rrcmpi/kudrov/smearing/logs"

for((i=${job_start};i<=${job_end};i++))
do
qsub -q long -v conf_num=${i},conf_chain=${conf_chain} -d $log_path /home/clusters/rrcmpi/kudrov/smearing/scripts/do.sh
while [ $? -ne 0 ]
do
qsub -q long -v conf_num=${i},conf_chain=${conf_chain} -d $log_path /home/clusters/rrcmpi/kudrov/smearing/scripts/do.sh
done
done

