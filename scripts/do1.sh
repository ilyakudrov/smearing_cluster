#!/bin/bash
#mu="0.00"
conf_size="24^4"
#conf_type="qc2dstag"
conf_type="su2_suzuki"
bites_skip=4

HYP_alpha1="1"
HYP_alpha2="1"
HYP_alpha3="0.5"
APE_alpha="0.6"
APE="1"
HYP="1"
APE_steps="32"
HYP_steps="1"

calculate_absent="false"

number_of_jobs=100

#for mu in "0.05" "0.35" "0.45"
for mu in "0.00"
do

source "/lustre/rrcmpi/kudrov/conf/${conf_type}/${conf_size}/mu${mu}/parameters"

script_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do.sh"

#chains=( "s0" )
#conf_start=( 201 )
#conf_end=( 201 )

#chains=( "/" )
#conf_start=( 31 )
#conf_end=( 400 )

for monopole in "/"
#for monopole in "monopoless" "/"
#for monopole in "/"
do

if [[ $monopole == "/" ]] ; then

matrix_type="su2"
conf_format="double_qc2dstag"
#conf_format="double_qc2dstag"
#smearing="HYP${HYP_steps}_APE${APE_steps_wilson}"

elif [[ $monopole == "monopoless" ]] ; then

matrix_type="su2"
#conf_format="double"
conf_format="double_fortran"
#smearing="HYP${HYP_steps}_APE${APE_steps_decomposition_wilson}"

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
#log_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing/${monopole}/SU2_dinam"
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
APE=${APE},HYP=${HYP},APE_steps=${APE_steps},HYP_steps=${HYP_steps},HYP_alpha1=${HYP_alpha1},HYP_alpha2=${HYP_alpha2},HYP_alpha3=${HYP_alpha3},APE_alpha=${APE_alpha}\
 -o "${log_path}/$a1$b1$c1$d1-$a2$b2$c2$d2.o" -e "${log_path}/$a1$b1$c1$d1-$a2$b2$c2$d2.e" ${script_path}
while [ $? -ne 0 ]
do
qsub -q long -v conf_type=${conf_type},matrix_type=${matrix_type},conf_format=${conf_format},L_spat=${L_spat},L_time=${L_time},\
conf_size=${conf_size},conf1=${conf1},conf2=${conf2},calculate_absent=${calculate_absent},monopole=${monopole},mu=${mu},chain=${chains[$chain_current]},\
APE=${APE},HYP=${HYP},APE_steps=${APE_steps},HYP_steps=${HYP_steps},HYP_alpha1=${HYP_alpha1},HYP_alpha2=${HYP_alpha2},HYP_alpha3=${HYP_alpha3},APE_alpha=${APE_alpha}\
 -o "${log_path}/$a1$b1$c1$d1-$a2$b2$c2$d2.o" -e "${log_path}/$a1$b1$c1$d1-$a2$b2$c2$d2.e" ${script_path}
done

if [[ $conf2 -ge ${conf_end[$chain_current]} ]] ; then
chain_current=$(( $chain_current + 1 ))
jobs_done=$(( ${i} + 1 ))
fi

done

done

done
