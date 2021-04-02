#!/bin/bash
#40^4 mu0.05
chains=( "s0" "s1" "s2" "s3" "s4" )
conf_start=( 201 5 5 5 5 )
#conf_end=( 637 436 423 433 419 )
conf_end=( 205 10 10 10 10 )

log_path="/home/clusters/rrcmpi/kudrov/smearing/logs"
for j in "${!chains[@]}"; do

for((i=${conf_start[j]};i<=${conf_end[j]};i++))
do
qsub -q long -v conf_num=${i},conf_chain=${chains[j]} -d $log_path /home/clusters/rrcmpi/kudrov/smearing/scripts/do_dep.sh
while [ $? -ne 0 ]
do
qsub -q long -v conf_num=${i},conf_chain=${chains[j]} -d $log_path /home/clusters/rrcmpi/kudrov/smearing/scripts/do_dep.sh
done
done
done

