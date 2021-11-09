#!/bin/bash
conf_size="32^4"
conf_type="qc2dstag"

APE_alpha="0.7"
APE_enabled=1
APE_steps=300
calculation_step_APE=30


#for mu in "0.05" "0.35" "0.45"
for mu in "0.00"
do

source "/lustre/rrcmpi/kudrov/conf/${conf_type}/${conf_size}/mu${mu}/parameters"
script_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do_dep_potential_spatial.sh"

#chains=( "s0" )
#conf_start=( 201 )
#conf_end=( 201 )

for monopole in "/" "monopoless"
#for monopole in "/"
do

if [[ $monopole == "/" ]] ; then

matrix_type="su2"
conf_format="double_qc2dstag"

elif [[ $monopole == "monopoless" ]] ; then

matrix_type="su2"
conf_format="double_fortran"

else

echo wrong monopole ${monopole}

fi

calculate_absent="false"

if [[ $conf_size == "40^4" ]] ; then

#T_min=6
#T_max=7
#R_min=6
#R_max=8

T_min=6
T_max=10
R_min=6
R_max=20

elif [[ $conf_size == "32^4" ]] ; then 

T_min=6
T_max=10
R_min=6
R_max=20

else

echo wrong conf_size ${conf_size}

fi


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

log_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing_test/potential_spatial/${monopole}/${conf_type}/${conf_size}/mu${mu}/${chains[${chain_current}]}"
mkdir -p ${log_path}

a1=$((${conf1}/1000))
b1=$(((${conf1}-$a1*1000)/100))
c1=$(((${conf1}-$a1*1000-$b1*100)/10))
d1=$((${conf1}-$a1*1000-$b1*100-$c1*10))

a2=$((${conf2}/1000))
b2=$(((${conf2}-$a2*1000)/100))
c2=$(((${conf2}-$a2*1000-$b2*100)/10))
d2=$((${conf2}-$a2*1000-$b2*100-$c2*10))

qsub -q long -v conf_format=${conf_format},matrix_type=${matrix_type},calculate_absent=${calculate_absent},chain=${chains[$chain_current]},monopole=${monopole},mu=${mu},conf1=${conf1},conf2=${conf2},\
L_spat=${L_spat},L_time=${L_time},T_min=${T_min},T_max=${T_max},R_min=${R_min},R_max=${R_max},conf_size=${conf_size},conf_type=${conf_type},APE_alpha=${APE_alpha},APE_enabled=${APE_enabled},APE_steps=${APE_steps},\
calculation_step_APE=${calculation_step_APE}\
 -o "${log_path}/$a1$b1$c1$d1-$a2$b2$c2$d2.o" -e "${log_path}/$a1$b1$c1$d1-$a2$b2$c2$d2.e" ${script_path}
while [ $? -ne 0 ]
do
qsub -q long -v conf_format=${conf_format},matrix_type=${matrix_type},calculate_absent=${calculate_absent},chain=${chains[$chain_current]},monopole=${monopole},mu=${mu},conf1=${conf1},conf2=${conf2},\
L_spat=${L_spat},L_time=${L_time},T_min=${T_min},T_max=${T_max},R_min=${R_min},R_max=${R_max},conf_size=${conf_size},conf_type=${conf_type},APE_alpha=${APE_alpha},APE_enabled=${APE_enabled},APE_steps=${APE_steps},\
calculation_step_APE=${calculation_step_APE}\
 -o "${log_path}/$a1$b1$c1$d1-$a2$b2$c2$d2.o" -e "${log_path}/$a1$b1$c1$d1-$a2$b2$c2$d2.e" ${script_path}
done

if [[ $conf2 -ge ${conf_end[$chain_current]} ]] ; then
chain_current=$(( $chain_current + 1 ))
jobs_done=$(( ${i} + 1 ))
fi

done

done

done
