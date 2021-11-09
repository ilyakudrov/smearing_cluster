#!/bin/bash
#mu="0.05"
conf_size="40^4"
#conf_type="SU2_dinam"
conf_type="qc2dstag"

#HYP_alpha1="0.75"
#HYP_alpha2="0.6"
#HYP_alpha3="0.3"
HYP_alpha1="1"
HYP_alpha2="1"
HYP_alpha3="0.5"
APE_alpha="0.65"
stout_alpha="0.15"
APE="1"
HYP="1"
stout="0"
APE_steps="25"
HYP_steps="1"
stout_steps="0"
wilson_enabled=1
smearing="HYP${HYP_steps}_alpha=${HYP_alpha1}_${HYP_alpha2}_${HYP_alpha3}_APE_alpha=${APE_alpha}"

calculate_absent="false"

T_min=4
T_max=14
R_min=1
R_max=16
#T_min=4
#T_max=5
#R_min=1
#R_max=2
calculation_step_APE=1

number_of_jobs=500

#for mu in "0.00" "0.05" "0.35" "0.45"
for mu in "0.45"
do

source "/lustre/rrcmpi/kudrov/conf/${conf_type}/${conf_size}/mu${mu}/parameters"

#chains=( "/" )
#conf_start=( 31 )
#conf_end=( 31 )

#for monopole in "/" "monopoless"
for monopole in "/"
do

if [[ $monopole == "/" ]] ; then

nothing="nothing"
#matrix_type="su2"
#conf_format="double"
#conf_format="double_qc2dstag"
#smearing="HYP${HYP_steps}_APE${APE_steps_wilson}"
#smearing="/"

elif [[ $monopole == "monopoless" ]] ; then

matrix_type="su2"
#conf_format="double"
conf_format="double_fortran"
#smearing="HYP${HYP_steps}_APE${APE_steps_decomposition_wilson}"
#smearing="/"

else

echo wrong monopole ${monopole}

fi

#conf_type="SU2_dinam"
#conf_format="float_fortran"
#matrix_type="su2"


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

#log_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing_test/${conf_type}/${conf_size}/mu${mu}/${chains[j]}"
#log_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing_test/monopoless/${conf_type}/${conf_size}/mu${mu}/${chains[j]}"
log_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing_test/potential/${monopole}/${conf_type}/${conf_size}/mu${mu}/${chains[${chain_current}]}"
mkdir -p ${log_path}

a1=$((${conf1}/1000))
b1=$(((${conf1}-$a1*1000)/100))
c1=$(((${conf1}-$a1*1000-$b1*100)/10))
d1=$((${conf1}-$a1*1000-$b1*100-$c1*10))

a2=$((${conf2}/1000))
b2=$(((${conf2}-$a2*1000)/100))
c2=$(((${conf2}-$a2*1000-$b2*100)/10))
d2=$((${conf2}-$a2*1000-$b2*100-$c2*10))

qsub -q long -v conf_format=${conf_format},HYP_alpha1=${HYP_alpha1},HYP_alpha2=${HYP_alpha2},HYP_alpha3=${HYP_alpha3},smearing=${smearing},\
APE_alpha=${APE_alpha},stout_alpha=${stout_alpha},APE=${APE},HYP=${HYP},stout=${stout},APE_steps=${APE_steps},HYP_steps=${HYP_steps},\
stout_steps=${stout_steps},wilson_enabled=${wilson_enabled},L_spat=${L_spat},L_time=${L_time},T_min=${T_min},T_max=${T_max},R_min=${R_min},R_max=${R_max},calculation_step_APE=${calculation_step_APE},chain=${chains[${chain_current}]},conf1=${conf1},conf2=${conf2},\
matrix_type=${matrix_type},calculate_absent=${calculate_absent},monopole=${monopole},conf_type=${conf_type},mu=${mu},conf_size=${conf_size} -o "${log_path}/$a1$b1$c1$d1.o" -e "${log_path}/$a2$b2$c2$d2.e" /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do_dep_potential.sh
while [ $? -ne 0 ]
do
qsub -q long -v conf_format=${conf_format},HYP_alpha1=${HYP_alpha1},HYP_alpha2=${HYP_alpha2},HYP_alpha3=${HYP_alpha3},smearing=${smearing},\
APE_alpha=${APE_alpha},stout_alpha=${stout_alpha},APE=${APE},HYP=${HYP},stout=${stout},APE_steps=${APE_steps},HYP_steps=${HYP_steps},\
stout_steps=${stout_steps},wilson_enabled=${wilson_enabled},L_spat=${L_spat},L_time=${L_time},T_min=${T_min},T_max=${T_max},R_min=${R_min},R_max=${R_max},calculation_step_APE=${calculation_step_APE},chain=${chains[${chain_current}]},conf1=${conf1},conf2=${conf2},\
matrix_type=${matrix_type},calculate_absent=${calculate_absent},monopole=${monopole},conf_type=${conf_type},mu=${mu},conf_size=${conf_size} -o "${log_path}/$a1$b1$c1$d1.o" -e "${log_path}/$a2$b2$c2$d2.e" /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do_dep_potential.sh
done

if [[ $conf2 -ge ${conf_end[$chain_current]} ]] ; then
chain_current=$(( $chain_current + 1 ))
jobs_done=$(( ${i} + 1 ))
fi

done
done

done
