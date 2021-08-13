#!/bin/bash
mu="0.45"
conf_size="40^4"

HYP_alpha1="0.75"
HYP_alpha2="0.6"
HYP_alpha3="0.3"
APE_alpha="0.7"
stout_alpha="0.15"
APE="1"
HYP="1"
stout="0"
APE_steps="290"
HYP_steps="2"
stout_steps="0"
smearing="HYP2_APE290"

calculate_absent=true

source "/lustre/rrcmpi/kudrov/conf/${conf_size}/mu${mu}/parameters"

conf_format="double_fortran"
#matrix_type="su2"
monopole="monopoless"
#monopole="monopole"
#monopole=""

#chains=( "" )
#conf_start=( 31 )
#conf_end=( 400 )

#chains=( "s0" )
#conf_start=( 201 )
#conf_end=( 201 )

for j in "${!chains[@]}"; do

log_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing/${monopole}/${conf_type}/${conf_size}/mu${mu}/${smearing}/${chains[j]}"
mkdir -p ${log_path}

for((i=${conf_start[j]};i<=${conf_end[j]};i++))
do

a=$(($i/1000))
b=$((($i-$a*1000)/100))
c=$((($i-$a*1000-$b*100)/10))
d=$(($i-$a*1000-$b*100-$c*10))

#conf_path="/home/clusters/rrcmpi/kudrov/conf/${conf_size}/mu${mu}/${chains[j]}/confs/CONF$a$b$c$d"
conf_path="/home/clusters/rrcmpi/kudrov/decomposition/confs_decomposed/${monopole}/qc2dstag/${conf_size}/mu${mu}/${chains[j]}/conf_${monopole}_$a$b$c$d"
#conf_path="/home/clusters/01/vborn/Copy_from_lustre/SU2_dinam/MAG/mu0p0_b1p8_m0p0075_lam0p00075/OFFD/CON_OFF_MAG_$b$c$d.LAT"

if [ -f ${conf_path} ] ; then

#smeared_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/confs_smeared/${conf_type}/${conf_size}/${smearing}/mu${mu}/${chains[j]}"
smeared_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/confs_smeared/${monopole}/${conf_type}/${conf_size}/${smearing}/mu${mu}/${chains[j]}"
#smeared_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/confs_smeared/${monopole}/su2_dynam/${conf_size}/${smearing}/mu${mu}"
mkdir -p ${smeared_path}
smeared_path="${smeared_path}/conf_APE_alpha=${APE_alpha}_$a$b$c$d"

if [ ! -f ${smeared_path} ] || [  ! ${calculate_absent} ] ; then

qsub -q long -v conf_path=${conf_path},conf_type=${conf_type},smeared_path=${smeared_path},matrix_type=${matrix_type},conf_format=${conf_format},L_spat=${L_spat},L_time=${L_time},\
conf_size=${conf_size},HYP_alpha1=${HYP_alpha1},HYP_alpha2=${HYP_alpha2},HYP_alpha3=${HYP_alpha3},APE_alpha=${APE_alpha},stout_alpha=${stout_alpha},\
APE=${APE},HYP=${HYP},stout=${stout},APE_steps=${APE_steps},HYP_steps=${HYP_steps},stout_steps=${stout_steps},\
 -o "${log_path}/$a$b$c$d.o" -e "${log_path}/$a$b$c$d.e"  /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do.sh
while [ $? -ne 0 ]
do
qsub -q long -v conf_path=${conf_path},conf_type=${conf_type},smeared_path=${smeared_path},matrix_type=${matrix_type},conf_format=${conf_format},L_spat=${L_spat},L_time=${L_time},\
conf_size=${conf_size},HYP_alpha1=${HYP_alpha1},HYP_alpha2=${HYP_alpha2},HYP_alpha3=${HYP_alpha3},APE_alpha=${APE_alpha},stout_alpha=${stout_alpha},\
APE=${APE},HYP=${HYP},stout=${stout},APE_steps=${APE_steps},HYP_steps=${HYP_steps},stout_steps=${stout_steps},\
 -o "${log_path}/$a$b$c$d.o" -e "${log_path}/$a$b$c$d.e"  /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do.sh
done

fi

fi

done
done
