#!/bin/bash
mu="0.45"
conf_size="40^4"
conf_type="qc2dstag"

APE="1"
HYP="1"
APE_steps="240"
HYP_steps="2"

calculate_absent=true

source "/lustre/rrcmpi/kudrov/conf/${conf_type}/${conf_size}/mu${mu}/parameters"

script_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do.sh"

#conf_format="double_fortran"
#matrix_type="su2"
#monopole="monopoless"
#monopole="monopole"
monopole="/"

number_of_jobs=100
confs_total=0

for i  in ${!chains[@]} ; do
confs_total=$(( $confs_total + ${conf_end[$i]} - ${conf_start[$i]} + 1 ))
done

confs_per_job=$(( ${confs_total} / ${number_of_jobs} + 1 ))
chain_current=0
jobs_done=0

for((i=0;i<${number_of_jobs};i++))
do

conf1=$(( ${conf_start[$chain_current]} + ${confs_per_job} * ($i - ${jobs_done}) ))
conf2=$(( ${conf_start[$chain_current]} + ${confs_per_job} * ($i - ${jobs_done} + 1) - 1 ))

if [[ $conf2 -ge ${conf_end[$chain_current]} ]] ; then
conf2=$(( ${conf_end[$chain_current]} ))
fi

if [[ $chain_current -ge ${#chains[@]} ]] ; then
break
fi

log_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing/${monopole}/${conf_type}/${conf_size}/mu${mu}/${smearing}/${chains[${chain_current}]}"
mkdir -p ${log_path}

#echo ${chains[${chain_current}]} $conf1-$conf2

a1=$((${conf1}/1000))
b1=$(((${conf1}-$a1*1000)/100))
c1=$(((${conf1}-$a1*1000-$b1*100)/10))
d1=$((${conf1}-$a1*1000-$b1*100-$c1*10))

a2=$((${conf2}/1000))
b2=$(((${conf2}-$a2*1000)/100))
c2=$(((${conf2}-$a2*1000-$b2*100)/10))
d2=$((${conf2}-$a2*1000-$b2*100-$c2*10))

#echo ${conf_type}
#echo ${matrix_type}
#echo ${conf_format}
#echo ${L_spat}
#echo ${L_time}
#echo ${conf_size}
#echo ${conf1}
#echo ${conf2}
#echo ${calculate_absent}
#echo ${monopole}
#echo ${mu}
#echo ${chains[$chain_current]}
#echo ${APE}
#echo ${HYP}
#echo ${APE_steps}
#echo ${HYP_steps}

#chain=$((${chains[chain_current]}))
#echo $chain

qsub -q long -v conf_type=${conf_type},matrix_type=${matrix_type},conf_format=${conf_format},L_spat=${L_spat},L_time=${L_time},\
conf_size=${conf_size},conf1=${conf1},conf2=${conf2},calculate_absent=${calculate_absent},monopole=${monopole},mu=${mu},chain=${chains[$chain_current]},\
APE=${APE},HYP=${HYP},APE_steps=${APE_steps},HYP_steps=${HYP_steps}\
 -o "${log_path}/$a1$b1$c1$d1-$a2$b2$c2$d2.o" -e "${log_path}/$a1$b1$c1$d1-$a2$b2$c2$d2.e" ${script_path}
while [ $? -ne 0 ]
do
qsub -q long -v conf_type=${conf_type},matrix_type=${matrix_type},conf_format=${conf_format},L_spat=${L_spat},L_time=${L_time},\
conf_size=${conf_size},conf1=${conf1},conf2=${conf2},calculate_absent=${calculate_absent},monopole=${monopole},mu=${mu},chain=${chains[$chain_current]},\
APE=${APE},HYP=${HYP},APE_steps=${APE_steps},HYP_steps=${HYP_steps}\
 -o "${log_path}/$a1$b1$c1$d1-$a2$b2$c2$d2.o" -e "${log_path}/$a1$b1$c1$d1-$a2$b2$c2$d2.e" ${script_path}
done

if [[ $conf2 -ge ${conf_end[$chain_current]} ]] ; then
chain_current=$(( $chain_current + 1 ))
jobs_done=$(( ${i} + 1 ))
fi

done
