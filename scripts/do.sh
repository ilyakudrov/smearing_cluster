#!/bin/bash

HYP_alpha1="0.75"
HYP_alpha2="0.6"
HYP_alpha3="0.3"
APE_alpha="0.7"
stout_alpha="0.15"
smearing="HYP${HYP_steps}_APE${APE_steps}"

for((i=$conf1;i<=${conf2};i++))
do

a=$(($i/1000))
b=$((($i-$a*1000)/100))
c=$((($i-$a*1000-$b*100)/10))
d=$(($i-$a*1000-$b*100-$c*10))

conf_path_qc2dstag="/home/clusters/rrcmpi/kudrov/conf/${conf_type}/${conf_size}/mu${mu}/$chain/confs/CONF$a$b$c$d"
conf_path_monopole="/home/clusters/rrcmpi/kudrov/decomposition/confs_decomposed/monopole/qc2dstag/${conf_size}/mu${mu}/$chain/conf_monopole_$a$b$c$d"
conf_path_monopoless="/home/clusters/rrcmpi/kudrov/decomposition/confs_decomposed/monopoless/qc2dstag/${conf_size}/mu${mu}/$chain/conf_monopoless_$a$b$c$d"

path1="conf_path_${monopole}"

if [[ ${monopole} == "/" ]] ; then

conf_path="$conf_path_qc2dstag"

else

conf_path=("${!path1}")

fi

if [ -f ${conf_path} ] ; then

smeared_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/confs_smeared/${monopole}/${conf_type}/${conf_size}/mu${mu}/${smearing}/$chain"
mkdir -p ${smeared_path}
smeared_path="${smeared_path}/conf_APE_alpha=${APE_alpha}_$a$b$c$d"

if [ ! -f ${smeared_path} ] || [  ! ${calculate_absent} ] ; then

parameters="-conf_format $conf_format -conf_path $conf_path -smeared_path $smeared_path -HYP_alpha1 $HYP_alpha1 -HYP_alpha2 $HYP_alpha2 -HYP_alpha3 $HYP_alpha3 -APE_alpha $APE_alpha -APE $APE -HYP $HYP -HYP_steps $HYP_steps -APE_steps $APE_steps -L_spat ${L_spat} -L_time ${L_time}"

/home/clusters/rrcmpi/kudrov/smearing_cluster/code/exe/smearing_${matrix_type} $parameters

fi
fi
done
