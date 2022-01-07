#!/bin/bash
#mu="0.05"
#conf_size="40^4"
conf_size="24^4"
#conf_type="SU2_dinam"
#conf_type="qc2dstag"
conf_type="su2_suzuki"
bites_skip=4

#HYP_alpha1="0.75"
#HYP_alpha2="0.6"
#HYP_alpha3="0.3"
HYP_alpha1="1"
HYP_alpha2="1"
HYP_alpha3="0.5"
APE_alpha="0.6"
stout_alpha="0.15"
APE="1"
HYP="1"
stout="0"
APE_steps="48"
HYP_steps="1"
stout_steps="0"
smearing="HYP${HYP_steps}_alpha=${HYP_alpha1}_${HYP_alpha2}_${HYP_alpha3}_APE_alpha=${APE_alpha}"

calculate_absent="false"

calculation_step_APE=5

number_of_jobs=100

#for mu in "0.00" "0.05" "0.35" "0.45"
for mu in "0.00"
do

source "/lustre/rrcmpi/kudrov/conf/${conf_type}/${conf_size}/mu${mu}/parameters"

#chains=( "s0" )
#conf_start=( 201 )
#conf_end=( 201 )

#for monopole in "/" "monopoless"
for monopole in "monopoless"
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

if [[ $conf_type == "su2_suzuki" ]] ; then

matrix_type="su2"
conf_format="float_fortran"
chains=( "/" )
conf_start=( 1 )
conf_end=( 100 )
L_spat=24
L_time=24

if [[ ${monopole} == "monopoless" ]] ; then

conf_format="double_fortran"
bites_skip=8

fi

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
log_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing_test/flux_tube_wilson/${monopole}/${conf_type}/${conf_size}/mu${mu}/${chains[${chain_current}]}"
mkdir -p ${log_path}

a1=$((${conf1}/1000))
b1=$(((${conf1}-$a1*1000)/100))
c1=$(((${conf1}-$a1*1000-$b1*100)/10))
d1=$((${conf1}-$a1*1000-$b1*100-$c1*10))

a2=$((${conf2}/1000))
b2=$(((${conf2}-$a2*1000)/100))
c2=$(((${conf2}-$a2*1000-$b2*100)/10))
d2=$((${conf2}-$a2*1000-$b2*100-$c2*10))

qsub -q long -v conf_format=${conf_format},bites_skip=${bites_skip},HYP_alpha1=${HYP_alpha1},HYP_alpha2=${HYP_alpha2},HYP_alpha3=${HYP_alpha3},smearing=${smearing},\
APE_alpha=${APE_alpha},stout_alpha=${stout_alpha},APE=${APE},HYP=${HYP},stout=${stout},APE_steps=${APE_steps},HYP_steps=${HYP_steps},\
stout_steps=${stout_steps},L_spat=${L_spat},L_time=${L_time},calculation_step_APE=${calculation_step_APE},chain=${chains[${chain_current}]},conf1=${conf1},conf2=${conf2},\
matrix_type=${matrix_type},calculate_absent=${calculate_absent},monopole=${monopole},conf_type=${conf_type},mu=${mu},conf_size=${conf_size} -o "${log_path}/$a1$b1$c1$d1.o" -e "${log_path}/$a2$b2$c2$d2.e" /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do_dep_flux_wilson.sh
while [ $? -ne 0 ]
do
qsub -q long -v conf_format=${conf_format},bites_skip=${bites_skip},HYP_alpha1=${HYP_alpha1},HYP_alpha2=${HYP_alpha2},HYP_alpha3=${HYP_alpha3},smearing=${smearing},\
APE_alpha=${APE_alpha},stout_alpha=${stout_alpha},APE=${APE},HYP=${HYP},stout=${stout},APE_steps=${APE_steps},HYP_steps=${HYP_steps},\
stout_steps=${stout_steps},L_spat=${L_spat},L_time=${L_time},calculation_step_APE=${calculation_step_APE},chain=${chains[${chain_current}]},conf1=${conf1},conf2=${conf2},\
matrix_type=${matrix_type},calculate_absent=${calculate_absent},monopole=${monopole},conf_type=${conf_type},mu=${mu},conf_size=${conf_size} -o "${log_path}/$a1$b1$c1$d1.o" -e "${log_path}/$a2$b2$c2$d2.e" /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do_dep_flux_wilson.sh
done

if [[ $conf2 -ge ${conf_end[$chain_current]} ]] ; then
chain_current=$(( $chain_current + 1 ))
jobs_done=$(( ${i} + 1 ))
fi

done
done

done
