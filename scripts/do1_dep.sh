#!/bin/bash
mu="0.05"
conf_size="40^4"
conf_type="qc2dstag"

HYP_alpha1="0.75"
HYP_alpha2="0.6"
HYP_alpha3="0.3"
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

source "/lustre/rrcmpi/kudrov/conf/${conf_type}/${conf_size}/mu${mu}/parameters"

conf_format="double_fortran"
#matrix_type="abelian"
monopole="monopoless"
#monopole=""

#chains=( "" )
#conf_start=( 201 )
#conf_end=( 201 )

for j in "${!chains[@]}"; do

#log_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing_test/${conf_type}/${conf_size}/mu${mu}/${chains[j]}"
#log_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing_test/monopoless/${conf_type}/${conf_size}/mu${mu}/${chains[j]}"
log_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing_test/wilson_loop/${monopole}/${conf_type}/${conf_size}/mu${mu}/${chains[j]}"
mkdir -p ${log_path}

for((i=${conf_start[j]};i<=${conf_end[j]};i++))
do

a=$(($i/1000))
b=$((($i-$a*1000)/100))
c=$((($i-$a*1000-$b*100)/10))
d=$(($i-$a*1000-$b*100-$c*10))

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

