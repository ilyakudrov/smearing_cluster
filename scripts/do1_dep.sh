#!/bin/bash
#mu="0.05"
conf_size="40^4"
conf_type="qc2dstag"

#HYP_alpha1="0.75"
#HYP_alpha2="0.6"
#HYP_alpha3="0.3"
APE_alpha="0.7"
stout_alpha="0.15"
APE="1"
HYP="1"
stout="0"
APE_steps="300"
HYP_steps="2"
stout_steps="0"
flux_enabled=1
wilson_enabled=1
smearing="HYP2_APE"

for mu in "0.05" "0.35" "0.45"
#for mu in "0.05"
do

source "/lustre/rrcmpi/kudrov/conf/${conf_type}/${conf_size}/mu${mu}/parameters"

#conf_format="double_fortran"
#matrix_type="abelian"
#monopole="monopoless"
#monopole=""

#chains=( "" )
#conf_start=( 201 )
#conf_end=( 201 )

for monopole in "/" "monopoless"
#for monopole in "monopoless"
do

if [[ $monopole == "/" ]] ; then

matrix_type="su2"
#conf_format="double"
conf_format="double_qc2dstag"
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

number_of_jobs=500
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
log_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing_test/wilson_loop/${monopole}/${conf_type}/${conf_size}/mu${mu}/${chains[${chain_current}]}"
mkdir -p ${log_path}

a1=$((${conf1}/1000))
b1=$(((${conf1}-$a1*1000)/100))
c1=$(((${conf1}-$a1*1000-$b1*100)/10))
d1=$((${conf1}-$a1*1000-$b1*100-$c1*10))

a2=$((${conf2}/1000))
b2=$(((${conf2}-$a2*1000)/100))
c2=$(((${conf2}-$a2*1000-$b2*100)/10))
d2=$((${conf2}-$a2*1000-$b2*100-$c2*10))


conf_path_="/home/clusters/rrcmpi/kudrov/conf/${conf_type}/${conf_size}/mu${mu}/${chains[j]}/confs/CONF$a$b$c$d"
conf_path_monopole="/home/clusters/rrcmpi/kudrov/decomposition/confs_decomposed/monopole/qc2dstag/${conf_size}/mu${mu}/${chains[j]}/conf_monopole_$a$b$c$d"
conf_path_monopoless="/home/clusters/rrcmpi/kudrov/decomposition/confs_decomposed/monopoless/qc2dstag/${conf_size}/mu${mu}/${chains[j]}/conf_monopoless_$a$b$c$d"

path1="conf_path_${monopole}"

conf_path=("${!path1}")

if [ -f ${conf_path} ] ; then

#wilson_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/smearing_test/result/wilson_loop/${conf_type}/${conf_size}/${smearing}/mu${mu}/${chains[j]}"
#wilson_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/smearing_test/result/wilson_loop/monopoless/${conf_type}/${conf_size}/${smearing}/mu${mu}/${chains[j]}"
wilson_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/smearing_test/result/wilson_loop/${monopole}/${conf_type}/${conf_size}/${smearing}/mu${mu}/${chains[j]}"
mkdir -p ${wilson_path}
wilson_path="${wilson_path}/wilson_loop_${APE_alpha}_$a$b$c$d"

#flux_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/smearing_test/result/flux_tube/${conf_type}/${conf_size}/${smearing}/mu${mu}/${chains[j]}"
#flux_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/smearing_test/result/flux_tube/monopoless/${conf_type}/${conf_size}/${smearing}/mu${mu}/${chains[j]}"
flux_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/smearing_test/result/flux_tube/${monopole}/${conf_type}/${conf_size}/${smearing}/mu${mu}/${chains[j]}"
mkdir -p ${flux_path}
flux_path="${flux_path}/flux_dep_${APE_alpha}_$a$b$c$d"

qsub -q long -v conf_path=${conf_path},conf_format=${conf_format},HYP_alpha1=${HYP_alpha1},HYP_alpha2=${HYP_alpha2},HYP_alpha3=${HYP_alpha3},\
APE_alpha=${APE_alpha},stout_alpha=${stout_alpha},APE=${APE},HYP=${HYP},stout=${stout},APE_steps=${APE_steps},HYP_steps=${HYP_steps},\
stout_steps=${stout_steps},flux_enabled=${flux_enabled},wilson_enabled=${wilson_enabled},L_spat=${L_spat},L_time=${L_time},\
wilson_path=${wilson_path},flux_path=${flux_path},matrix_type=${matrix_type} -o "${log_path}/$a$b$c$d.o" -e "${log_path}/$a$b$c$d.e" /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do_dep.sh
while [ $? -ne 0 ]
do
qsub -q long -v conf_path=${conf_path},conf_format=${conf_format},HYP_alpha1=${HYP_alpha1},HYP_alpha2=${HYP_alpha2},HYP_alpha3=${HYP_alpha3},\
APE_alpha=${APE_alpha},stout_alpha=${stout_alpha},APE=${APE},HYP=${HYP},stout=${stout},APE_steps=${APE_steps},HYP_steps=${HYP_steps},\
stout_steps=${stout_steps},flux_enabled=${flux_enabled},wilson_enabled=${wilson_enabled},L_spat=${L_spat},L_time=${L_time},\
wilson_path=${wilson_path},flux_path=${flux_path},matrix_type=${matrix_type} -o "${log_path}/$a$b$c$d.o" -e "${log_path}/$a$b$c$d.e" /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do_dep.sh
done

fi

done
done

